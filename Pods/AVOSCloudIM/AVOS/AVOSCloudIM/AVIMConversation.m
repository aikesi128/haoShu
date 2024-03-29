//
//  AVIMConversation.m
//  AVOSCloudIM
//
//  Created by Qihe Bian on 12/4/14.
//  Copyright (c) 2014 LeanCloud Inc. All rights reserved.
//

#import "AVIMConversation.h"
#import "AVIMCommon.h"
#import "AVIMConversation_Internal.h"
#import "AVIMClient.h"
#import "AVIMClient_Internal.h"
#import "AVIMBlockHelper.h"
#import "AVIMTypedMessage_Internal.h"
#import "AVIMConversationUpdateBuilder_Internal.h"
#import "AVIMGeneralObject.h"
#import "AVIMConversationQuery.h"
#import "LCIMMessageCache.h"
#import "LCIMMessageCacheStore.h"
#import "AVIMKeyedConversation_internal.h"
#import "AVErrorUtils.h"
#import "AVFile_Internal.h"
#import "AVIMUserOptions.h"
#import "AVIMErrorUtil.h"
#import "LCIMConversationCache.h"
#import "MessagesProtoOrig.pbobjc.h"
#import "AVUtils.h"
#import "AVIMRuntimeHelper.h"

#define LCIM_VALID_LIMIT(limit) ({      \
    int32_t limit_ = (int32_t)(limit);  \
    if (limit_ <= 0)   limit = 20;      \
                                        \
    BOOL useUnread = [[AVIMClient userOptions][AVIMUserOptionUseUnread] boolValue];  \
    int32_t max = useUnread ? 100 : 1000;  \
                                        \
    if (limit_ > max) limit = max;      \
    limit_;                             \
})

#define LCIM_DISTANT_FUTURE_TIMESTAMP \
    ([[NSDate distantFuture] timeIntervalSince1970] * 1000)

#define LCIM_VALID_TIMESTAMP(timestamp) ({      \
    int64_t timestamp_ = (int64_t)(timestamp);  \
    if (timestamp_ <= 0) timestamp_ = LCIM_DISTANT_FUTURE_TIMESTAMP;  \
    timestamp_;  \
})

NSString *LCIMClientIdKey = @"clientId";
NSString *LCIMConversationIdKey = @"conversationId";
NSString *LCIMConversationPropertyNameKey = @"propertyName";
NSString *LCIMConversationPropertyValueKey = @"propertyValue";
NSNotificationName LCIMConversationPropertyUpdateNotification = @"LCIMConversationPropertyUpdateNotification";

@interface AVIMConversation()

@property (nonatomic, strong) NSMutableDictionary *propertiesForUpdate;

@end

@implementation AVIMConversation

static dispatch_queue_t messageCacheOperationQueue;

+ (void)initialize {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        messageCacheOperationQueue = dispatch_queue_create("leancloud.message-cache-operation-queue", DISPATCH_QUEUE_CONCURRENT);
    });
}

- (instancetype)init {
    self = [super init];

    if (self) {
        [self doInitialize];
    }

    return self;
}

- (instancetype)initWithConversationId:(NSString *)conversationId {
    self = [self init];

    if (self) {
        _conversationId = [conversationId copy];
    }

    return self;
}

- (void)doInitialize {
    _properties = [NSMutableDictionary dictionary];
    _propertiesForUpdate = [NSMutableDictionary dictionary];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(propertyDidUpdate:)
                                                 name:LCIMConversationPropertyUpdateNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)propertyDidUpdate:(NSNotification *)notification {
    if (!self.conversationId)
        return;

    NSDictionary *userInfo = notification.userInfo;

    NSString *clientId = userInfo[LCIMClientIdKey];
    NSString *conversationId = userInfo[LCIMConversationIdKey];
    NSString *propertyName = userInfo[LCIMConversationPropertyNameKey];
    NSString *propertyValue = userInfo[LCIMConversationPropertyValueKey];

    if (!propertyName
        || (!clientId || ![clientId isEqualToString:self.imClient.clientId])
        || (!conversationId || ![conversationId isEqualToString:self.conversationId]))
        return;

    [self setValue:propertyValue forKey:propertyName];

    AVIMClient *client = self.imClient;
    SEL delegateMethod = @selector(conversation:didUpdateForKey:);

    if ([client.delegate respondsToSelector:delegateMethod])
        [AVIMRuntimeHelper callMethodInMainThreadWithTarget:client.delegate
                                                   selector:delegateMethod
                                                  arguments:@[self, propertyName]];
}

- (NSString *)clientId {
    return _imClient.clientId;
}

- (AVIMMessage *)lastMessage {
    if (_lastMessage) {
        return _lastMessage;
    }
    if (!_lastMessageAt || !self.imClient.messageQueryCacheEnabled) {
        return nil;
    }
    [AVUtils warnMainThreadIfNecessary];
    NSArray *cachedMessages = [[self messageCacheStore] latestMessagesWithLimit:1];
    AVIMMessage *message = [cachedMessages lastObject];
    if (message) {
        _lastMessage = message;
        return _lastMessage;
    }
    return nil;
}

- (void)setImClient:(AVIMClient *)imClient {
    _imClient = imClient;
}

- (void)setConversationId:(NSString *)conversationId {
    _conversationId = [conversationId copy];
}

- (void)setMembers:(NSArray *)members {
    _members = members;
}

- (void)setProperties:(NSMutableDictionary *)properties {
    if (properties)
        _properties = properties;
    else
        _properties = [NSMutableDictionary dictionary];
}

- (void)setObject:(nullable id)object forKey:(NSString *)key {
    [self.propertiesForUpdate setObject:object forKey:key];
    [self.properties setObject:object forKey:key];
}

- (void)setObject:(id)object forKeyedSubscript:(NSString *)key {
    [self setObject:object forKey:key];
}

- (nullable id)objectForKey:(NSString *)key {
    id object = (
        [self.propertiesForUpdate objectForKey:key] ?:
        [self.properties objectForKey:key]
    );

    return object;
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self objectForKey:key];
}

- (void)cleanAttributesForUpdate {
    [self.propertiesForUpdate removeAllObjects];
}

- (AVIMConversationUpdateBuilder *)newUpdateBuilder {
    AVIMConversationUpdateBuilder *builder = [[AVIMConversationUpdateBuilder alloc] init];
    return builder;
}

- (void)addMembers:(NSArray *)members {
    if (members.count > 0) {
        self.members = ({
            NSMutableOrderedSet *allMembers = [NSMutableOrderedSet orderedSetWithArray:self.members ?: @[]];
            [allMembers addObjectsFromArray:members];
            [allMembers array];
        });
    }
}

- (void)addMember:(NSString *)clientId {
    if (clientId) {
        [self addMembers:@[clientId]];
    }
}

- (void)removeMembers:(NSArray *)members {
    if (members.count > 0) {
        if (_members.count > 0) {
            NSMutableArray *array = [_members mutableCopy];
            [array removeObjectsInArray:members];
            self.members = [array copy];
        }
    }
}

- (void)removeMember:(NSString *)clientId {
    if (clientId) {
        [self removeMembers:@[clientId]];
    }
}

- (void)setCreator:(NSString *)creator {
    _creator = creator;
}

- (NSString *)name {
    return self.properties[KEY_NAME];
}

- (void)setName:(NSString *)name {
    self.properties[KEY_NAME] = name;
}

- (NSDictionary *)attributes {
    return self.properties[KEY_ATTR];
}

- (void)setAttributes:(NSDictionary *)attributes {
    self.properties[KEY_ATTR] = attributes;
}

- (void)fetchWithCallback:(AVIMBooleanResultBlock)callback {
    AVIMConversationQuery *query = [self.imClient conversationQuery];
    query.cachePolicy = kAVCachePolicyNetworkOnly;
    [query getConversationById:self.conversationId callback:^(AVIMConversation *conversation, NSError *error) {
        dispatch_async([AVIMClient imClientQueue], ^{
            [conversation lastMessage];
            if (conversation && conversation != self) {
                [self setKeyedConversation:[conversation keyedConversation]];
            }
            [AVIMBlockHelper callBooleanResultBlock:callback error:error];
        });
    }];
}

- (void)fetchReceiptTimestampsInBackground {
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];

        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.op = AVIMOpType_MaxRead;
        genericCommand.peerId = self.imClient.clientId;

        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (error)
                return;

            AVIMConvCommand *convCommand = inCommand.convMessage;
            NSDate *lastDeliveredAt = [NSDate dateWithTimeIntervalSince1970:convCommand.maxAckTimestamp / 1000.0];
            NSDate *lastReadAt = [NSDate dateWithTimeIntervalSince1970:convCommand.maxReadTimestamp / 1000.0];

            [self.imClient updateReceipt:lastDeliveredAt
                          ofConversation:self
                                  forKey:NSStringFromSelector(@selector(lastDeliveredAt))];

            [self.imClient updateReceipt:lastReadAt
                          ofConversation:self
                                  forKey:NSStringFromSelector(@selector(lastReadAt))];
        }];

        [self.imClient sendCommand:genericCommand];
    });
}

- (void)joinWithCallback:(AVIMBooleanResultBlock)callback {
    [self addMembersWithClientIds:@[_imClient.clientId] callback:callback];
}

- (void)addMembersWithClientIds:(NSArray *)clientIds callback:(AVIMBooleanResultBlock)callback {
    [[AVIMClient class] _assertClientIdsIsValid:clientIds];
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.peerId = _imClient.clientId;
        genericCommand.op = AVIMOpType_Add;
        
        AVIMConvCommand *command = [[AVIMConvCommand alloc] init];
        command.cid = self.conversationId;
        command.mArray = [NSMutableArray arrayWithArray:clientIds];
        NSString  *actionString = [AVIMCommandFormatter signatureActionForKey:genericCommand.op];
        NSString *clientIdString = [NSString stringWithFormat:@"%@",genericCommand.peerId];
        NSArray *clientIds = [command.mArray copy];
        AVIMSignature *signature = [_imClient signatureWithClientId:clientIdString conversationId:command.cid action:actionString actionOnClientIds:clientIds];
        [genericCommand avim_addRequiredKeyWithCommand:command];
        [genericCommand avim_addRequiredKeyForConvMessageWithSignature:signature];
        if ([AVIMClient checkErrorForSignature:signature command:genericCommand]) {
            return;
        }
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                AVIMConvCommand *conversationOutCommand = outCommand.convMessage;
                [self addMembers:[conversationOutCommand.mArray copy]];
                [self removeCachedConversation];
                [AVIMBlockHelper callBooleanResultBlock:callback error:nil];
            } else {
                [AVIMBlockHelper callBooleanResultBlock:callback error:error];
            }
        }];
        

        [_imClient sendCommand:genericCommand];
    });
}

- (void)quitWithCallback:(AVIMBooleanResultBlock)callback {
    [self removeMembersWithClientIds:@[_imClient.clientId] callback:callback];
}

- (void)removeMembersWithClientIds:(NSArray *)clientIds callback:(AVIMBooleanResultBlock)callback {
    NSString *myClientId = _imClient.clientId;
    
    [[AVIMClient class] _assertClientIdsIsValid:clientIds];
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.peerId = _imClient.clientId;
        genericCommand.op = AVIMOpType_Remove;
        
        AVIMConvCommand *command = [[AVIMConvCommand alloc] init];
        command.cid = self.conversationId;
        command.mArray = [NSMutableArray arrayWithArray:clientIds];
        NSString *actionString = [AVIMCommandFormatter signatureActionForKey:genericCommand.op];
        NSString *clientIdString = [NSString stringWithFormat:@"%@",genericCommand.peerId];
        NSArray *clientIds = [command.mArray copy];
        
        AVIMSignature *signature = [_imClient signatureWithClientId:clientIdString conversationId:command.cid action:actionString actionOnClientIds:clientIds];
        [genericCommand avim_addRequiredKeyWithCommand:command];
        [genericCommand avim_addRequiredKeyForConvMessageWithSignature:signature];
        if ([AVIMClient checkErrorForSignature:signature command:genericCommand]) {
            return;
        }
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                AVIMConvCommand *conversationOutCommand = outCommand.convMessage;
                [self removeMembers:[conversationOutCommand.mArray copy]];
                [self removeCachedConversation];
                if ([clientIds containsObject:myClientId]) {
                    [self removeCachedMessages];
                }

                [AVIMBlockHelper callBooleanResultBlock:callback error:nil];
            } else {
                [AVIMBlockHelper callBooleanResultBlock:callback error:error];
            }
        }];
        
        [_imClient sendCommand:genericCommand];
    });
}

- (void)countMembersWithCallback:(AVIMIntegerResultBlock)callback {
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.peerId = _imClient.clientId;
        genericCommand.op = AVIMOpType_Count;
        
        AVIMConvCommand *command = [[AVIMConvCommand alloc] init];
        command.cid = self.conversationId;
        
        [genericCommand avim_addRequiredKeyWithCommand:command];
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                AVIMConvCommand *conversationInCommand = inCommand.convMessage;
                [AVIMBlockHelper callIntegerResultBlock:callback number:conversationInCommand.count error:nil];
            } else {
                [AVIMBlockHelper callIntegerResultBlock:callback number:0 error:nil];
            }
        }];
        [_imClient sendCommand:genericCommand];
    });
}

- (AVIMGenericCommand *)generateGenericCommandWithAttributes:(NSDictionary *)attributes {
    AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
    genericCommand.needResponse = YES;
    genericCommand.cmd = AVIMCommandType_Conv;
    genericCommand.peerId = self.imClient.clientId;
    
    AVIMConvCommand *convCommand = [[AVIMConvCommand alloc] init];
    convCommand.cid = self.conversationId;
    genericCommand.op = AVIMOpType_Update;
    convCommand.attr = [AVIMCommandFormatter JSONObjectWithDictionary:attributes];
    [genericCommand avim_addRequiredKeyWithCommand:convCommand];
    return genericCommand;
}

- (void)updateLocalAttributes:(NSDictionary *)attributes {
    NSString *name = attributes[KEY_NAME];
    NSDictionary *attr = attributes[KEY_ATTR];

    if (name)
        self.name = name;

    if (attr) {
        NSMutableDictionary *attributes = (
            self.attributes ?
            [NSMutableDictionary dictionaryWithDictionary:self.attributes] :
            [NSMutableDictionary dictionary]
        );

        [attributes addEntriesFromDictionary:attr];

        self.attributes = attributes;
    }
}

- (void)updateWithCallback:(AVIMBooleanResultBlock)callback {
    [self updateAttributes:self.propertiesForUpdate callback:callback];
}

- (void)update:(NSDictionary *)attributes callback:(AVIMBooleanResultBlock)callback {
    [self updateAttributes:attributes callback:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error)
            [self updateLocalAttributes:attributes];

        [AVIMBlockHelper callBooleanResultBlock:callback error:error];
    }];
}

- (void)updateAttributes:(NSDictionary *)attributes callback:(AVIMBooleanResultBlock)callback {
    attributes = [attributes copy];

    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [self generateGenericCommandWithAttributes:attributes];
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                [self cleanAttributesForUpdate];
                [self removeCachedConversation];
            }
            if (callback)
                callback(error == nil, error);
        }];
        [_imClient sendCommand:genericCommand];
    });
}

- (void)muteWithCallback:(AVIMBooleanResultBlock)callback {
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.peerId = _imClient.clientId;
        genericCommand.op = AVIMOpType_Mute;
        
        AVIMConvCommand *convCommand = [[AVIMConvCommand alloc] init];
        convCommand.cid = self.conversationId;
        [genericCommand avim_addRequiredKeyWithCommand:convCommand];
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                self.muted = YES;
                [self removeCachedConversation];
                [AVIMBlockHelper callBooleanResultBlock:callback error:nil];
            } else {
                [AVIMBlockHelper callBooleanResultBlock:callback error:error];
            }
        }];
        [_imClient sendCommand:genericCommand];
    });
}

- (void)unmuteWithCallback:(AVIMBooleanResultBlock)callback {
    dispatch_async([AVIMClient imClientQueue], ^{
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Conv;
        genericCommand.peerId = _imClient.clientId;
        genericCommand.op = AVIMOpType_Unmute;
        
        AVIMConvCommand *convCommand = [[AVIMConvCommand alloc] init];
        convCommand.cid = self.conversationId;
        [genericCommand avim_addRequiredKeyWithCommand:convCommand];
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                self.muted = NO;
                [self removeCachedConversation];
                [AVIMBlockHelper callBooleanResultBlock:callback error:nil];
            } else {
                [AVIMBlockHelper callBooleanResultBlock:callback error:error];
            }
        }];
        [_imClient sendCommand:genericCommand];
    });
}

- (void)markAsReadInBackground {
    __weak typeof(self) ws = self;
    
    dispatch_async([AVIMClient imClientQueue], ^{
        [ws.imClient sendCommand:({
            AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
            genericCommand.needResponse = YES;
            genericCommand.cmd = AVIMCommandType_Read;
            genericCommand.peerId = ws.imClient.clientId;
            
            AVIMReadCommand *readCommand = [[AVIMReadCommand alloc] init];
            readCommand.cid = ws.conversationId;
            [genericCommand avim_addRequiredKeyWithCommand:readCommand];
            genericCommand;
        })];
    });
}

- (void)readInBackground {
    dispatch_async([AVIMClient imClientQueue], ^{
        int64_t lastTimestamp = 0;
        NSString *lastMessageId = nil;

        /* NOTE:
           We do not care about the owner of last message.
           Server will do the right thing.
         */
        AVIMMessage *lastMessage = self.lastMessage;

        if (lastMessage) {
            lastTimestamp = lastMessage.sendTimestamp;
            lastMessageId = lastMessage.messageId;
        } else if (self.lastMessageAt)
            lastTimestamp = [self.lastMessageAt timeIntervalSince1970] * 1000;

        if (lastTimestamp <= 0) {
            AVLoggerInfo(AVLoggerDomainIM, @"No message to read.");
            return;
        }

        AVIMReadTuple *readTuple = [[AVIMReadTuple alloc] init];
        AVIMReadCommand *readCommand = [[AVIMReadCommand alloc] init];
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];

        readTuple.cid = self.conversationId;
        readTuple.mid = lastMessageId;
        readTuple.timestamp = lastTimestamp;

        readCommand.convsArray = [NSMutableArray arrayWithObject:readTuple];

        genericCommand.cmd = AVIMCommandType_Read;
        genericCommand.peerId = self.imClient.clientId;

        [genericCommand avim_addRequiredKeyWithCommand:readCommand];

        [self.imClient resetUnreadMessagesCountForConversation:self];
        [self.imClient sendCommand:genericCommand];
    });
}

- (void)sendMessage:(AVIMMessage *)message
           callback:(AVIMBooleanResultBlock)callback
{
    [self sendMessage:message option:nil callback:callback];
}

- (void)sendMessage:(AVIMMessage *)message
             option:(AVIMMessageOption *)option
           callback:(AVIMBooleanResultBlock)callback
{
    [self sendMessage:message option:option progressBlock:nil callback:callback];
}

- (void)sendMessage:(AVIMMessage *)message
      progressBlock:(AVProgressBlock)progressBlock
           callback:(AVIMBooleanResultBlock)callback
{
    [self sendMessage:message option:nil progressBlock:progressBlock callback:callback];
}

- (void)sendMessage:(AVIMMessage *)message
            options:(AVIMMessageSendOption)options
           callback:(AVIMBooleanResultBlock)callback
{
    [self sendMessage:message
              options:options
        progressBlock:nil
             callback:callback];
}

- (void)sendMessage:(AVIMMessage *)message
            options:(AVIMMessageSendOption)options
      progressBlock:(AVProgressBlock)progressBlock
           callback:(AVIMBooleanResultBlock)callback
{
    AVIMMessageOption *option = [[AVIMMessageOption alloc] init];

    if (options & AVIMMessageSendOptionTransient)
        option.transient = YES;

    if (options & AVIMMessageSendOptionRequestReceipt)
        option.receipt = YES;

    [self sendMessage:message option:option progressBlock:progressBlock callback:callback];
}

- (void)sendMessage:(AVIMMessage *)message
             option:(AVIMMessageOption *)option
      progressBlock:(AVProgressBlock)progressBlock
           callback:(AVIMBooleanResultBlock)callback
{
    message.clientId = _imClient.clientId;
    message.conversationId = _conversationId;
    if (self.imClient.status != AVIMClientStatusOpened) {
        message.status = AVIMMessageStatusFailed;
        NSError *error = [AVIMErrorUtil errorWithCode:kAVIMErrorClientNotOpen reason:@"You can only send message when the status of the client is opened."];
        [AVIMBlockHelper callBooleanResultBlock:callback error:error];
        return;
    }
    message.status = AVIMMessageStatusSending;
    
    if ([message isKindOfClass:[AVIMTypedMessage class]]) {
        AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
        
        AVFile *file = nil;
        
        if (typedMessage.file) {
            file = typedMessage.file;
        } else if (typedMessage.attachedFilePath) {
            NSString *attachedFilePath = typedMessage.attachedFilePath;
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:attachedFilePath]) {
                [AVIMBlockHelper callBooleanResultBlock:callback error:[AVErrorUtils fileNotFoundError]];
                return;
            }
            
            NSString *name = [attachedFilePath lastPathComponent];
            
            file = [AVFile fileWithName:name contentsAtPath:attachedFilePath];
        }
        
        if (file) {
            if ([file isDirty]) {
                /* File need to be uploaded */
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        /* If uploading is success, bind file to message */
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            [self fillTypedMessage:typedMessage withFile:file];
                            [self fillTypedMessageForLocationIfNeeded:typedMessage];
                            [self sendRealMessage:message option:option callback:callback];
                        });
                    } else {
                        message.status = AVIMMessageStatusFailed;
                        [AVIMBlockHelper callBooleanResultBlock:callback error:error];
                    }
                } progressBlock:progressBlock];
            } else {
                /* File has already been uploaded, bind file to message */
                [self fillTypedMessage:typedMessage withFile:file];
                [self fillTypedMessageForLocationIfNeeded:typedMessage];
                [self sendRealMessage:message option:option callback:callback];
            }
        } else {
            [self fillTypedMessageForLocationIfNeeded:typedMessage];
            [self sendRealMessage:message option:option callback:callback];
        }
    } else {
        [self sendRealMessage:message option:option callback:callback];
    }
}

- (void)fillTypedMessage:(AVIMTypedMessage *)typedMessage withFile:(AVFile *)file {
    typedMessage.file = file;
    
    AVIMGeneralObject *object = [[AVIMGeneralObject alloc] init];
    
    object.url = file.url;
    object.objId = file.objectId;
    
    switch (typedMessage.mediaType) {
        case kAVIMMessageMediaTypeImage: {
            UIImage *image = [[UIImage alloc] initWithData:[file getData]];
            CGFloat width = image.size.width;
            CGFloat height = image.size.height;
            
            AVIMGeneralObject *metaData = [[AVIMGeneralObject alloc] init];
            metaData.height = height;
            metaData.width = width;
            metaData.size = file.size;
            metaData.format = [file.name pathExtension];
            
            file.metaData = [[metaData dictionary] mutableCopy];
            
            object.metaData = metaData;
            typedMessage.messageObject._lcfile = [object dictionary];
        }
            break;
            
        case kAVIMMessageMediaTypeAudio:
        case kAVIMMessageMediaTypeVideo: {
            NSString *path = file.localPath;
            
            /* If audio file not found, no meta data */
            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                break;
            }
            
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
            CMTime audioDuration = audioAsset.duration;
            float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
            
            AVIMGeneralObject *metaData = [[AVIMGeneralObject alloc] init];
            metaData.duration = audioDurationSeconds;
            metaData.size = file.size;
            metaData.format = [file.name pathExtension];
            
            file.metaData = [[metaData dictionary] mutableCopy];
            
            object.metaData = metaData;
            typedMessage.messageObject._lcfile = [object dictionary];
        }
            break;
        case kAVIMMessageMediaTypeFile:
        default: {
            /* 文件消息或扩展的文件消息 */
            object.name = file.name;
            /* Compatibility with IM protocol */
            object.size = file.size;
            
            /* Compatibility with AVFile implementation, see [AVFile size] method */
            AVIMGeneralObject *metaData = [[AVIMGeneralObject alloc] init];
            metaData.size = file.size;
            object.metaData = metaData;
            
            typedMessage.messageObject._lcfile = [object dictionary];
        }
            break;
    }
}

- (void)fillTypedMessageForLocationIfNeeded:(AVIMTypedMessage *)typedMessage {
    AVGeoPoint *location = typedMessage.location;
    
    if (location) {
        AVIMGeneralObject *object = [[AVIMGeneralObject alloc] init];
        
        object.latitude = location.latitude;
        object.longitude = location.longitude;
        
        typedMessage.messageObject._lcloc = [object dictionary];
    }
}

- (void)sendRealMessage:(AVIMMessage *)message option:(AVIMMessageOption *)option callback:(AVIMBooleanResultBlock)callback {
    dispatch_async([AVIMClient imClientQueue], ^{
        BOOL will = option.will;
        BOOL transient = option.transient;
        BOOL receipt = option.receipt;

        if ([message isKindOfClass:[AVIMTypedMessage class]]) {
            AVIMTypedMessage *typedMessage = (AVIMTypedMessage *)message;
            if (!typedMessage.messageObject._lctext && !typedMessage.messageObject._lcloc && !typedMessage.messageObject._lcfile && !typedMessage.messageObject._lcattrs) {
                [NSException raise:NSInternalInconsistencyException format:@"AVIMTypedMessage should have one of text, file, location or attributes not be nil."];
            }
        }

        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.needResponse = YES;
        genericCommand.cmd = AVIMCommandType_Direct;

        if (option.priority > 0) {
            if (self.transient) {
                genericCommand.priority = option.priority;
            } else {
                AVLoggerInfo(AVLoggerDomainIM, @"Message priority has no effect in non-transient conversation.");
            }
        }

        AVIMDirectCommand *directCommand = [[AVIMDirectCommand alloc] init];
        [genericCommand avim_addRequiredKeyWithCommand:directCommand];
        [genericCommand avim_addRequiredKeyForDirectMessageWithMessage:message transient:NO];

        if (will) {
            directCommand.will = YES;
        }
        if (transient) {
            directCommand.transient = YES;
            genericCommand.needResponse = NO;
        }
        if (receipt) {
            directCommand.r = YES;
        }
        if (option.pushData) {
            if (option.transient || self.transient) {
                AVLoggerInfo(AVLoggerDomainIM, @"Push data cannot applied to transient message or transient conversation.");
            } else {
                NSError *error = nil;
                NSData  *data  = [NSJSONSerialization dataWithJSONObject:option.pushData options:0 error:&error];

                if (error) {
                    AVLoggerInfo(AVLoggerDomainIM, @"Push data cannot be serialize to JSON string. Error: %@.", error.localizedDescription);
                } else {
                    directCommand.pushData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
            }
        }

        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            AVIMDirectCommand *directOutCommand = outCommand.directMessage;
            AVIMMessage *message = outCommand.directMessage.message;
            
            if (error) {
                message.status = AVIMMessageStatusFailed;
            } else {
                message.status = AVIMMessageStatusSent;
                
                AVIMAckCommand *ackInCommand = inCommand.ackMessage;
                message.sendTimestamp = ackInCommand.t;
                message.messageId = ackInCommand.uid;
                if (!transient) {
                    self.lastMessage = message;
                }
                if (!directCommand.transient && self.imClient.messageQueryCacheEnabled) {
                    [[self messageCacheStore] insertMessage:message withBreakpoint:NO];
                }
                if (!transient) {
                    if (directOutCommand.r) {
                        [_imClient stageMessage:message];
                    }
                    [self updateConversationAfterSendMessage:message];
                }
            }
            [AVIMBlockHelper callBooleanResultBlock:callback error:error];
        }];
        
        [_imClient sendCommand:genericCommand];
    });
}

- (void)updateConversationAfterSendMessage:(AVIMMessage *)message {
    NSDate *messageSentAt = [NSDate dateWithTimeIntervalSince1970:(message.sendTimestamp / 1000.0)];
    self.lastMessageAt = messageSentAt;
    [self.conversationCache updateConversationForLastMessageAt:messageSentAt conversationId:self.conversationId];
}

#pragma mark -

- (NSArray *)takeContinuousMessages:(NSArray *)messages {
    NSMutableArray *continuousMessages = [NSMutableArray array];
    
    for (AVIMMessage *message in messages.reverseObjectEnumerator) {
        if (!message.breakpoint) {
            [continuousMessages insertObject:message atIndex:0];
        } else {
            break;
        }
    }
    
    return continuousMessages;
}

- (LCIMMessageCache *)messageCache {
    NSString *clientId = self.clientId;

    return clientId ? [LCIMMessageCache cacheWithClientId:clientId] : nil;
}

- (LCIMMessageCacheStore *)messageCacheStore {
    NSString *clientId = self.clientId;
    NSString *conversationId = self.conversationId;

    return clientId && conversationId ? [[LCIMMessageCacheStore alloc] initWithClientId:clientId conversationId:conversationId] : nil;
}

- (LCIMConversationCache *)conversationCache {
    NSString *clientId = self.clientId;

    return clientId ? [[LCIMConversationCache alloc] initWithClientId:clientId] : nil;
}

- (void)cacheContinuousMessages:(NSArray *)messages {
    [self cacheContinuousMessages:messages withBreakpoint:YES];

    [self messagesDidCache];
}

- (void)cacheContinuousMessages:(NSArray *)messages plusMessage:(AVIMMessage *)message {
    NSMutableArray *cachedMessages = [NSMutableArray array];
    
    if (messages) [cachedMessages addObjectsFromArray:messages];
    if (message)  [cachedMessages addObject:message];
    
    [self cacheContinuousMessages:cachedMessages withBreakpoint:YES];

    [self messagesDidCache];
}

- (void)cacheContinuousMessages:(NSArray *)messages withBreakpoint:(BOOL)breakpoint {
    if (breakpoint) {
        [[self messageCache] addContinuousMessages:messages forConversationId:self.conversationId];
    } else {
        [[self messageCacheStore] insertMessages:messages];
    }

    [self messagesDidCache];
}

- (void)messagesDidCache {
    AVIMMessage *lastMessage = [[self queryMessagesFromCacheWithLimit:1] firstObject];

    if (lastMessage) {
        LCIM_NOTIFY_PROPERTY_UPDATE(
            self.clientId,
            self.conversationId,
            NSStringFromSelector(@selector(lastMessage)),
            lastMessage);

        NSDate *lastMessageAt = [NSDate dateWithTimeIntervalSince1970:(lastMessage.sendTimestamp / 1000.0)];

        LCIM_NOTIFY_PROPERTY_UPDATE(
            self.clientId,
            self.conversationId,
            NSStringFromSelector(@selector(lastMessageAt)),
            lastMessageAt);
    }
}

- (void)removeCachedConversation {
    [[self conversationCache] removeConversationForId:self.conversationId];
}

- (void)removeCachedMessages {
    [[self messageCacheStore] cleanCache];
}

#pragma mark - Message Query

- (void)sendACKIfNeeded:(NSArray *)messages {
    NSDictionary *userOptions = [AVIMClient userOptions];
    BOOL useUnread = [userOptions[AVIMUserOptionUseUnread] boolValue];
    
    if (useUnread) {
        AVIMClient *client = self.imClient;
        AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
        genericCommand.cmd = AVIMCommandType_Ack;
        genericCommand.needResponse = YES;
        genericCommand.peerId = client.clientId;
        
        AVIMAckCommand *ackOutCommand = [[AVIMAckCommand alloc] init];
        ackOutCommand.cid = self.conversationId;
        int64_t fromts = [[messages firstObject] sendTimestamp];
        int64_t tots   = [[messages lastObject] sendTimestamp];
        ackOutCommand.fromts = MIN(fromts, tots);
        ackOutCommand.tots   = MAX(fromts, tots);
        [genericCommand avim_addRequiredKeyWithCommand:ackOutCommand];
        [client sendCommand:genericCommand];
    }
}

- (void)queryMessagesFromServerWithCommand:(AVIMGenericCommand *)genericCommand
                                  callback:(AVIMArrayResultBlock)callback
{
    AVIMLogsCommand *logsOutCommand = genericCommand.logsMessage;
    dispatch_async([AVIMClient imClientQueue], ^{
        [genericCommand setCallback:^(AVIMGenericCommand *outCommand, AVIMGenericCommand *inCommand, NSError *error) {
            if (!error) {
                AVIMLogsCommand *logsInCommand = inCommand.logsMessage;
                AVIMLogsCommand *logsOutCommand = outCommand.logsMessage;
                NSArray *logs = [logsInCommand.logsArray copy];
                NSMutableArray *messages = [[NSMutableArray alloc] init];
                for (AVIMLogItem *logsItem in logs) {
                    AVIMMessage *message = nil;
                    id data = [logsItem data_p];
                    if (![data isKindOfClass:[NSString class]]) {
                        AVLoggerError(AVOSCloudIMErrorDomain, @"Received an invalid message.");
                        continue;
                    }
                    AVIMTypedMessageObject *messageObject = [[AVIMTypedMessageObject alloc] initWithJSON:data];
                    if ([messageObject isValidTypedMessageObject]) {
                        AVIMTypedMessage *m = [AVIMTypedMessage messageWithMessageObject:messageObject];
                        message = m;
                    } else {
                        AVIMMessage *m = [[AVIMMessage alloc] init];
                        m.content = data;
                        message = m;
                    }
                    message.conversationId = logsOutCommand.cid;
                    message.sendTimestamp = [logsItem timestamp];
                    message.clientId = [logsItem from];
                    message.messageId = [logsItem msgId];
                    [messages addObject:message];
                }
                self.lastMessage = messages.lastObject;
                [self postprocessMessages:messages];
                [self sendACKIfNeeded:messages];
                
                [AVIMBlockHelper callArrayResultBlock:callback array:messages error:nil];
            } else {
                [AVIMBlockHelper callArrayResultBlock:callback array:nil error:error];
            }
        }];
        [genericCommand avim_addRequiredKeyWithCommand:logsOutCommand];
        [_imClient sendCommand:genericCommand];
    });
}

- (void)queryMessagesFromServerBeforeId:(NSString *)messageId
                              timestamp:(int64_t)timestamp
                                  limit:(NSUInteger)limit
                               callback:(AVIMArrayResultBlock)callback
{
    AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
    genericCommand.needResponse = YES;
    genericCommand.cmd = AVIMCommandType_Logs;
    genericCommand.peerId = _imClient.clientId;
    
    AVIMLogsCommand *logsCommand = [[AVIMLogsCommand alloc] init];
    logsCommand.cid    = _conversationId;
    logsCommand.mid    = messageId;
    logsCommand.t      = LCIM_VALID_TIMESTAMP(timestamp);
    logsCommand.l      = LCIM_VALID_LIMIT(limit);
    
    [genericCommand avim_addRequiredKeyWithCommand:logsCommand];
    [self queryMessagesFromServerWithCommand:genericCommand callback:callback];
}

- (void)queryMessagesFromServerBeforeId:(NSString *)messageId
                              timestamp:(int64_t)timestamp
                            toMessageId:(NSString *)toMessageId
                            toTimestamp:(int64_t)toTimestamp
                                  limit:(NSUInteger)limit
                               callback:(AVIMArrayResultBlock)callback
{
    AVIMGenericCommand *genericCommand = [[AVIMGenericCommand alloc] init];
    AVIMLogsCommand *logsCommand = [[AVIMLogsCommand alloc] init];
    genericCommand.needResponse = YES;
    genericCommand.cmd = AVIMCommandType_Logs;
    genericCommand.peerId = _imClient.clientId;
    logsCommand.cid    = _conversationId;
    logsCommand.mid    = messageId;
    logsCommand.tmid   = toMessageId;
    logsCommand.tt     = MAX(toTimestamp, 0);
    logsCommand.t      = MAX(timestamp, 0);
    logsCommand.l      = LCIM_VALID_LIMIT(limit);
    [genericCommand avim_addRequiredKeyWithCommand:logsCommand];
    [self queryMessagesFromServerWithCommand:genericCommand callback:callback];
}

- (void)queryMessagesFromServerWithLimit:(NSUInteger)limit
                                callback:(AVIMArrayResultBlock)callback
{
    limit = LCIM_VALID_LIMIT(limit);
    
    [self queryMessagesFromServerBeforeId:nil
                                timestamp:LCIM_DISTANT_FUTURE_TIMESTAMP
                                    limit:limit
                                 callback:^(NSArray *messages, NSError *error)
     {
         if (self.imClient.messageQueryCacheEnabled) {
             dispatch_async(messageCacheOperationQueue, ^{
                 [self cacheContinuousMessages:messages];
                 [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
             });
         } else {
             [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
         }
     }];
}

- (NSArray *)queryMessagesFromCacheWithLimit:(NSUInteger)limit {
    limit = LCIM_VALID_LIMIT(limit);
    NSArray *cachedMessages = [[self messageCacheStore] latestMessagesWithLimit:limit];
    [self postprocessMessages:cachedMessages];
    
    return cachedMessages;
}

- (void)queryMessagesWithLimit:(NSUInteger)limit
                      callback:(AVIMArrayResultBlock)callback
{
    limit = LCIM_VALID_LIMIT(limit);
    
    BOOL socketOpened = self.imClient.status == AVIMClientStatusOpened;
    // 如果屏蔽了本地缓存则全部走网络
    if (!self.imClient.messageQueryCacheEnabled) {
        if (!socketOpened) {
            NSError *error = [AVIMErrorUtil errorWithCode:kAVIMErrorClientNotOpen reason:@"Client not open when query messages from server."];
            [AVIMBlockHelper callArrayResultBlock:callback array:nil error:error];
            return;
        }
        [self queryMessagesFromServerWithLimit:limit callback:callback];
        return;
    }
    if (socketOpened) {
        /* If connection is open, query messages from server */
        [self queryMessagesFromServerBeforeId:nil
                                    timestamp:LCIM_DISTANT_FUTURE_TIMESTAMP
                                  toMessageId:nil
                                  toTimestamp:0
                                        limit:limit
                                     callback:^(NSArray *messages, NSError *error)
         {
             if (!error) {
                 [AVIMBlockHelper callArrayResultBlock:callback array:messages error:nil];
                 dispatch_async(messageCacheOperationQueue, ^{
                     [self cacheContinuousMessages:messages withBreakpoint:YES];
                 });
             } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
                 /* If network has an error, fallback to query from cache */
                 NSArray *messages = [self queryMessagesFromCacheWithLimit:limit];
                 [AVIMBlockHelper callArrayResultBlock:callback array:messages error:nil];
             } else {
                 /* If error is not network relevant, return it */
                 [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
             }
         }];
    } else {
        /* Otherwise, query messages from cache */
        NSArray *messages = [self queryMessagesFromCacheWithLimit:limit];
        [AVIMBlockHelper callArrayResultBlock:callback array:messages error:nil];
    }
}

- (void)queryMessagesBeforeId:(NSString *)messageId
                    timestamp:(int64_t)timestamp
                        limit:(NSUInteger)limit
                     callback:(AVIMArrayResultBlock)callback
{
    limit     = LCIM_VALID_LIMIT(limit);
    timestamp = LCIM_VALID_TIMESTAMP(timestamp);

    /*
     * Firstly, if message query cache is not enabled, just forward query request.
     */
    if (!self.imClient.messageQueryCacheEnabled) {
        [self queryMessagesFromServerBeforeId:messageId
                                    timestamp:timestamp
                                        limit:limit
                                     callback:^(NSArray *messages, NSError *error)
         {
             [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
         }];
        return;
    }

    /*
     * Secondly, if message query cache is enabled, fetch message from cache.
     */
    dispatch_async(messageCacheOperationQueue, ^{
        BOOL continuous = YES;
        LCIMMessageCache *cache = [self messageCache];
        LCIMMessageCacheStore *cacheStore = [self messageCacheStore];
        AVIMMessage *fromMessage = [cacheStore messageForId:messageId];
        NSArray *cachedMessages = [cache messagesBeforeTimestamp:timestamp
                                                       messageId:messageId
                                                  conversationId:self.conversationId
                                                           limit:limit
                                                      continuous:&continuous];
        
        [self postprocessMessages:cachedMessages];
        
        /*
         * If message is continuous or socket connect is not opened, return fetched messages directly.
         */
        BOOL socketOpened = self.imClient.status == AVIMClientStatusOpened;
        
        if ((continuous && [cachedMessages count] == limit) || !socketOpened) {
            [AVIMBlockHelper callArrayResultBlock:callback array:cachedMessages error:nil];
            return;
        }
        
        /*
         * If cached messages exist, only fetch the rest uncontinuous messages.
         */
        if ([cachedMessages count] > 0) {
            NSArray *continuousMessages = [self takeContinuousMessages:cachedMessages];
            
            BOOL hasContinuous = [continuousMessages count] > 0;
            
            /*
             * Then, fetch rest of messages from remote server.
             */
            NSUInteger restCount = 0;
            AVIMMessage *startMessage = nil;
            
            if (hasContinuous) {
                restCount = limit - [continuousMessages count];
                startMessage = [continuousMessages firstObject];
            } else {
                restCount = limit;
                AVIMMessage *last = [cachedMessages lastObject];
                startMessage = [cache nextMessageForMessage:last
                                             conversationId:self.conversationId];
            }
            
            /*
             * If start message not nil, query messages before it.
             */
            if (startMessage) {
                [self queryMessagesFromServerBeforeId:startMessage.messageId
                                            timestamp:startMessage.sendTimestamp
                                                limit:restCount
                                             callback:^(NSArray *messages, NSError *error)
                 {
                     if (!messages) {
                         messages = @[];
                     }
                     
                     NSMutableArray *fetchedMessages = [NSMutableArray arrayWithArray:messages];
                     
                     if (hasContinuous) {
                         [fetchedMessages addObjectsFromArray:continuousMessages];
                     }
                     
                     [AVIMBlockHelper callArrayResultBlock:callback array:fetchedMessages error:nil];

                     dispatch_async(messageCacheOperationQueue, ^{
                         [self cacheContinuousMessages:fetchedMessages plusMessage:fromMessage];
                     });
                 }];
            } else {
                /*
                 * Otherwise, just forward query request.
                 */
                [self queryMessagesFromServerBeforeId:messageId
                                            timestamp:timestamp
                                                limit:limit
                                             callback:^(NSArray *messages, NSError *error)
                 {
                     dispatch_async(messageCacheOperationQueue, ^{
                         [self cacheContinuousMessages:messages plusMessage:fromMessage];
                         [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
                     });
                 }];
            }
        } else {
            /*
             * Otherwise, just forward query request.
             */
            [self queryMessagesFromServerBeforeId:messageId
                                        timestamp:timestamp
                                            limit:limit
                                         callback:^(NSArray *messages, NSError *error)
             {
                 dispatch_async(messageCacheOperationQueue, ^{
                     [self cacheContinuousMessages:messages plusMessage:fromMessage];
                     [AVIMBlockHelper callArrayResultBlock:callback array:messages error:error];
                 });
             }];
        }
    });
}

- (void)postprocessMessages:(NSArray *)messages {
    for (AVIMMessage *message in messages) {
        message.status = AVIMMessageStatusSent;
        message.localClientId = self.imClient.clientId;
    }
}

#pragma mark - Keyed Conversation

- (AVIMKeyedConversation *)keyedConversation {
    AVIMKeyedConversation *keyedConversation = [[AVIMKeyedConversation alloc] init];
    
    keyedConversation.conversationId = self.conversationId;
    keyedConversation.clientId       = self.imClient.clientId;
    keyedConversation.creator        = self.creator;
    keyedConversation.createAt       = self.createAt;
    keyedConversation.updateAt       = self.updateAt;
    keyedConversation.lastMessageAt  = self.lastMessageAt;
    keyedConversation.lastMessage    = self.lastMessage;
    keyedConversation.name           = self.name;
    keyedConversation.members        = self.members;
    keyedConversation.attributes     = self.attributes;
    keyedConversation.transient      = self.transient;
    keyedConversation.muted          = self.muted;
    
    return keyedConversation;
}

- (void)setKeyedConversation:(AVIMKeyedConversation *)keyedConversation {
    self.conversationId    = keyedConversation.conversationId;
    self.creator           = keyedConversation.creator;
    self.createAt          = keyedConversation.createAt;
    self.updateAt          = keyedConversation.updateAt;
    self.lastMessageAt     = keyedConversation.lastMessageAt;
    self.lastMessage       = keyedConversation.lastMessage;
    self.name              = keyedConversation.name;
    self.members           = keyedConversation.members;
    self.attributes        = keyedConversation.attributes;
    self.transient         = keyedConversation.transient;
    self.muted             = keyedConversation.muted;
}

@end
