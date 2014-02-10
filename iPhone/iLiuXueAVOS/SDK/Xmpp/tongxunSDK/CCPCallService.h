/*
 *  Copyright (c) 2013 The CCP project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a Beijing Speedtong Information Technology Co.,Ltd license
 *  that can be found in the LICENSE file in the root of the web site.
 *
 *                    http://www.cloopen.com
 *
 *  An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <UIKit/UIKit.h>
#import "CommonClass.h"
#define ShieldMosaic
enum EReason {
    EReasonNone,
    EReasonNoResponse,
    EReasonBadCredentials,
    EReasonDeclined,
    EReasonNotFound,
    EReasonCallMissed,
    EReasonBusy,
    EReasonNoNetwork,
    EReasonReFetchSoftSwitch,
    EReasonKickedOff,
    EReasonCalleeNoVoip
};

enum EMessageFailedResult {
    EMessageFailed,                 //发送短信失败
    EMessageRegisterFailed,         //没有注册
};

enum EVoipCallType{
    EVoipCallType_Voice = 0,
    EVoipCallType_Video
};

enum ENETWORK_STATUS{
    NETWORK_STATUS_NONE,
    NETWORK_STATUS_LAN,
    NETWORK_STATUS_WIFI,
    NETWORK_STATUS_GPRS,
    NETWORK_STATUS_3G
};

enum ECCPResult{
    ECCP_Success = 0,               //成功
    ECCP_Sending = 1,               //发送中
    ECCP_Failed  = -1               //失败
};

typedef enum  {
    Codec_iLBC = 0,
    Codec_G729,
    Codec_PCMU,
    Codec_PCMA,
    Codec_VP8,
    Codec_H264
} Codec;

typedef enum
{
    phonePolicyNoFirewall = 0,
    phonePolicyUseIce
} APPFirewallPolicy;

@class StatisticsInfo;

@interface CCPCallService : NSObject

#pragma mark - 初始化函数
//初始化呼叫(初始化和注册一起)
- (CCPCallService *)initWithDelegate:(id)delegate;
//设置代理方法
- (void)setDelegate:(id)delegate;
//注册
- (NSInteger)connectToCCP:(NSString *)proxy_addr onPort:(NSInteger)proxy_port withAccount:(NSString *)accountStr withPsw:(NSString *)passwordStr withAccountSid:(NSString *)accountSid withAuthToken:(NSString *)authToken;

#pragma mark - 呼叫控制函数
/**
 * 拨打电话
 * @param callType 电话类型
 * @param called 电话号(加国际码)或者VoIP号码
 * @return 本次电话的id
 */
- (NSString *)makeCallWithType:(NSInteger)callType andCalled:(NSString *)called;

/**
 * 回拨电话
 * @param src 主叫的电话（加国际码）
 * @param dest 被叫的电话（加国际码）
 */
- (NSInteger)makeCallback:(NSString *)src withTOCall:(NSString *)dest;

/**
 * 挂断电话
 * @param callid 电话id
 * @param reason 预留参数
 */
- (NSInteger)releaseCall:(NSString *)callid;

/**
 * 接听电话
 * @param callid 电话id
 * V2.0
 */
- (NSInteger)acceptCall:(NSString*)callid;

/**
 * 接听电话
 * @param callid 电话id
 * @param callType 电话类型
 * V2.1
 */
- (NSInteger)acceptCall:(NSString*)callid withType:(NSInteger)callType;

/**
 * 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 * @param callid 电话id
 */
- (NSInteger)rejectCall:(NSString*)callid;

/**
 * 暂停通话
 * @param callid 电话id
 */
- (NSInteger)pauseCall:(NSString*)callid;

/**
 * 恢复通话
 * @param callid 电话id
 */
- (NSInteger)resumeCall:(NSString*)callid;

/**
 * 转接电话
 * @param callid 电话id
 * @param destination 转接目标电话
 */
- (NSInteger)transferCall:(NSString*)callid withTransferID:(NSString *)destination;

/**
 * 获取当前通话的callid
 * @return 电话id
 */
-(NSString*)getCurrentCall;

//获取呼叫的媒体类型
- (NSInteger)getCallMediaType:(NSString*)callid;

//更新已存在呼叫的媒体类型
- (NSInteger)updateCallMedia:(NSString*)callid withType:(NSInteger)callType;

//回复对方的更新请求
- (NSInteger)answerCallMediaUpdate:(NSString*)callid withAction:(NSInteger)action;

/**
 * 获取当前状态
 * @return 状态值
 */
- (BOOL)isOnline;

#pragma mark - DTMF函数
/**
 * 发送DTMF
 * @param callid 电话id
 * @param dtmf 键值
 */
- (NSInteger)sendDTMF:(NSString *)callid dtmf:(NSString *)dtmf;

#pragma mark - 基本设置函数

/**
 * 静音设置
 * @param on false:正常 true:静音
 */
- (NSInteger)setMute:(BOOL)on;

/**
 * 获取当前静音状态
 * @return false:正常 true:静音
 */
- (NSInteger)getMuteStatus;

/**
 * 获取当前免提状态
 * @return false:关闭 true:打开
 */
- (NSInteger)getLoudsSpeakerStatus;

/**
 * 免提设置
 * @param enable false:关闭 true:打开
 */
- (NSInteger)enableLoudsSpeaker:(BOOL)enable;

//重置音频设备,应用挂起时调用无效，切换前台后马上调用容易失败，因为设备此时还未初始化完毕，如果想要启动后调用，可以在切换到前台后延时调用。
- (NSInteger)resetAudio:(BOOL)flag;
/**
 * 设置电话
 * @param phoneNumber 电话号
 */
- (void)setSelfPhoneNumber:(NSString *)phoneNumber;

/**
 * 设置昵称
 * @param nickName 昵称
 */
- (void)setSelfName:(NSString *)nickName;

/**
 * 设置视频通话显示的view
 * @param view 对方显示视图
 * @param localView 本地显示视图
 */
- (NSInteger)setVideoView:(UIView*)view andLocalView:(UIView*)localView;

/**
 * 获取摄像设备信息
 * @return 摄像设备信息数组
 */
- (NSArray*)getCameraInfo;

/**
 * 选择使用的摄像设备
 * @param cameraIndex 设备index
 * @param capabilityIndex 能力index
 * @param fps 帧率
 * @param rotate 旋转的角度
 */
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(Rotate)rotate;

/**
 * 设置支持的编解码方式，默认全部都支持
 * @param codec 编解码类型
 * @param enabled 0:不支持 1:支持
 */
-(void)setCodecEnabledWithCodec:(Codec) codec andEnabled:(BOOL) enabled;

//设置客户端标示
- (void)setUserAgent:(NSString *)agent;

/**
* 设置音频处理的开关,在呼叫前调用
* @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
* @param enabled AGC默认关闭; EC和NS默认开启.
* @param mode: 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
* @return  成功 0 失败 -1
*/
-(NSInteger)setAudioConfigEnabledWithType:(EAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode;

/**
 * 设置视频通话码率
 * @param bitrates  视频码流，kb/s，范围30-300
 */
-(void)setVideoBitRates:(NSInteger)bitrates;


/**
* 保存Rtp数据到文件，只能在通话过程中调用，如果没有调用stopRtpDump，通话结束后底层会自动调用
* @param callid    回话ID
* @param mediaType 媒体类型， 0：音频 1：视频
* @param fileName  文件名
* @paramdirection  需要保存RTP的方向，0：接收 1：发送
* @return     成功 0 失败 -1 
*/
-(NSInteger) startRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType andFileName:(NSString*)fileName andDirection:(NSInteger) direction;

/**
* 停止保存RTP数据，只能在通话过程中调用。
* @param   callid :  回话ID
* @param   mediaType: 媒体类型， 0：音频 1：视频
* @param   direction: 需要保存RTP的方向，0：接收 1：发送
* @return  成功 0 失败 -1
*/
-(NSInteger) stopRtpDump:(NSString*)callid andMediaType:(NSInteger) mediaType  andDirection:(NSInteger) direction;

/**
 * 返回版本信息
 * @ret  返回版本信息
 */
-(NSString*)getSDKVersion;

/**
 *统计通话质量
 */
-(StatisticsInfo*)getCallStatistics;

//是否抑制马赛克
-(NSInteger) setShieldMosaic:(BOOL) flag;

#pragma mark - 实时对讲相关函数
/**
 * 创建实时对讲场景
 * @param members 邀请的对讲成员
 * @param appId 应用id
 */
- (void) startInterphoneWithJoiner:(NSArray*)members inAppId:(NSString*)appId;

/**
 * 加入实时对讲
 * @param confNo 实时对讲会议号
 */
- (void) joinInterphoneToConfNo:(NSString*)confNo;

/**
 * 退出当前实时对讲
 * @return false:失败 true:成功
 */
- (BOOL) exitInterphone;

/**
 * 实时对讲中，控麦
 * @param confNo 实时对讲会议号
 */
- (void) controlMicInConfNo:(NSString*)confNo;

/**
 * 实时对讲中，放麦
 * @param confNo 实时对讲会议号
 */
- (void) releaseMicInConfNo:(NSString*)confNo;

/**
 * 查询实时对讲中成员
 * @param confNo 实时对讲会议号
 */
- (void) queryMembersWithInterphone:(NSString*)confNo;

#pragma mark - 聊天室相关函数
/**
 * 创建群聊室
 * @param appId 应用id
 * @param roomName 房间名称
 * @param square 参与的最大方数
 * @param keywords 业务属性，有应用定义
 * @param roomPwd 房间密码，可为null
 */
- (void) startChatroomInAppId:(NSString*)appId withName:(NSString *)roomName andSquare:(NSInteger)square andKeywords:(NSString *)keywords andPassword:(NSString *)roomPwd;

/**
 * 加入聊天室
 * @param roomNo 房间号
 */
- (void) joinChatroomInRoom:(NSString *)roomNo;

/**
 * 退出当前聊天室
 * @return false:失败 true:成功
 */
- (BOOL) exitChatroom;

/**
 * 查询聊天室成员
 * @param roomNo 房间号
 */
- (void) queryMembersWithChatroom:(NSString *)roomNo;

/**
 * 查询聊天室列表
 * @param appId 应用id
 * @param keywords 业务属性
 */
- (void)queryChatroomsOfAppId:(NSString *)appId withKeywords:(NSString *)keywords;

/**
 * 外呼邀请成员加入聊天室
 * @param members 被邀请者的电话
 * @param roomNo 房间号
 * @param appId 应用id
 */
- (void)inviteMembers:(NSArray*)members joinChatroom:(NSString*)roomNo ofAppId:(NSString *)appId;

/**
 * 解散聊天室
 * @param appId 应用id
 * @param roomNo 房间号
 */
- (void) dismissChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo;

/**
 * 踢出聊天室成员
 * @param appId 应用id
 * @param roomNo 房间号
 * @param member 成员号码
 */
- (void) removeMemberFromChatroomWithAppId:(NSString*) appId andRoomNo:(NSString*) roomNo andMember:(NSString*) member;

//设置语音SRTP加密属性
-(NSInteger) setSrtpWithKey:(NSString*) key;

#pragma mark - 多媒体IM
/**
 * 发送录音
 * @param receiver  接收方的VoIP账号或群组id
 * @param path      音频文件本地保存路径
 * @param chunked   是否进行边录边上传
 * @param userdata  用户自定义数据 最大支持255个字符
 */
- (NSString*) startVoiceRecordingWithReceiver:(NSString*) receiver andPath:(NSString*) path andChunked:(BOOL) chunked andUserdata:(NSString*)userdata;

// 停止录音
-(void)stopVoiceRecording;

//取消录音上传chunked
- (void) cancelVoiceRecording;

/**
 * 播放语音文件
 * @param fileName 语音路径
 */
-(void)playVoiceMsg:(NSString*) path;

/**
 * 停止播放语音
 */
-(void)stopVoiceMsg;

/**
 * 获取语音文件时长
 * @param fileName 语音路径
 * @return 时长，单位ms
 */
-(long)getVoiceDuration:(NSString*) fileName;

/**
 * 发送多媒体信息及文本信息
 * @param receiver 接收方的VoIP账号或者是群组Id
 * @param text 发送内容。长度140字符
 * @param attached 附件的路径
 * @param userdata 用户自定义数据 最大支持255个字符  
 * @return 函数返回字符串 表示msgId
 */
- (NSString*) sendInstanceMessage:(NSString*) receiver andText:(NSString*) text andAttached:(NSString*) attached andUserdata:(NSString*)userdata;


/*下载附件API，该API根据数组中DownLoadInfo对象里的fileUrl字段进行下载，DownLoadInfo对象里的isChunked字段用来标示是否通过Chunked方式下载，默认是非Chunked方式下载，传入YES则使用Chunked方式下载；完成下载后通过onDownloadAttachedWithReason回调接口返回下载状态。*/
/**
 * 下载附件
 * @param 下载文件DownloadInfo数组
 */
- (void) downloadAttached:(NSArray*)urlList;

/**
 * 确认已成功下载IM附件
 * @param 消息id数组
 */
- (void) confirmInstanceMessageWithMsgId:(NSArray*) msgIds;


@end
