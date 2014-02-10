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
#import "CommonClass.h"

#ifndef CPPCallManagerSDK_CCPType_h
#define CPPCallManagerSDK_CCPType_h

@class InterphoneMsg;

@protocol CCPCallEventDelegate<NSObject>
/********************初始化回调********************/
@required
//与云通讯平台连接成功
- (void)onConnected;
//与云通讯平台连接失败或连接断开
- (void)onConnectError:(NSInteger)reason withReasonMessge:(NSString *)reasonMessage;
//注销成功
- (void)onDisconnect;

@optional
/********************系统事件回调********************/
//事件通知
- (void)onReceiveEvents:(CCPEvents) events;
//P2P连接成功
- (void)onFirewallPolicyEnabled;
//网络连接状态, status 值为ENETWORK_STATUS
- (void)onReachbilityChanged:(NSInteger)status;

//音频设备开始中断
- (void)onAudioBeginInterruption;
//音频设备结束终端
- (void)onAudioEndInterruption;

/********************VoIP通话的方法********************/
//有呼叫进入
- (void)onIncomingCallReceived:(NSString*)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(NSInteger)calltype;
//呼叫处理中
- (void)onCallProceeding:(NSString *)callid;
//呼叫振铃
- (void)onCallAlerting:(NSString*)callid;
//所有应答
- (void)onCallAnswered:(NSString *)callid;
//外呼失败
- (void)onMakeCallFailed:(NSString *)callid withReason:(NSInteger)reason;
//本地Pause呼叫成功
- (void)onCallPaused:(NSString *)callid;
//呼叫被对端pasue
- (void)onCallPausedByRemote:(NSString *)callid;
//本地resume呼叫成功
- (void)onCallResumed:(NSString *)callid;
//呼叫被对端resume
- (void)onCallResumedByRemote:(NSString *)callid;
//呼叫挂机
- (void)onCallReleased:(NSString *)callid;
//呼叫被转接
- (void)onCallTransfered:(NSString *)callid transferTo:(NSString *)destination;

//收到对方请求的更新媒体
- (void)onCallMediaUpdate:(NSString *)callid withRequest:(NSInteger)request;

//对方应答请求更新媒体
- (void)onCallMediaUpdate:(NSString *)callid withResponse:(NSInteger)response;

//视频分辨率发生改变
//resolution eg.240*320
- (void)onCallVideoRatioChanged:(NSString *)callid withResolution:(NSString *)resolution;

//呼叫时，媒体初始化失败
- (void)onCallMediaInitFailed:(NSString *)callid  withMediaType:(NSInteger) mediaType withReason:(NSInteger)reason;

@optional
//回拨回调
- (void)onCallBackWithReason:(NSInteger)reason andFrom:(NSString*)src To:(NSString*)dest;


/********************实时对讲的方法********************/

//通知客户端收到新的实时对讲邀请信息（接收到实时对讲的Push消息）
- (void)onReceiveInterphoneMsg:(InterphoneMsg*) msg;

//启动对讲场景状态（实时对讲状态回调方法）
- (void)onInterphoneStateWithReason:(NSInteger) reason andConfNo:(NSString*)confNo;

//发起对讲——抢麦（控麦状态回调方法）
- (void)onControlMicStateWithReason:(NSInteger) reason andSpeaker:(NSString*)speaker;

//结束对讲——放麦（放麦状态回调方法）
- (void)onReleaseMicStateWithReason:(NSInteger) reason;

//获取对讲场景的成员
- (void)onInterphoneMembersWithReason:(NSInteger) reason andData:(NSArray*)members;

/********************聊天室的方法********************/
//通知客户端收到新的聊天室信息
- (void)onReceiveChatroomMsg:(ChatroomMsg*) msg;

//聊天室状态
- (void)onChatroomStateWithReason:(NSInteger) reason andRoomNo:(NSString*)roomNo;

//获取聊天室的成员
- (void)onChatroomMembersWithReason:(NSInteger) reason andData:(NSArray*)members;

//获取聊天室（获取房间列表回调方法）
- (void)onChatroomsWithReason:(NSInteger) reason andRooms:(NSArray*)chatrooms;

//邀请加入聊天室
- (void)onChatroomInviteMembersWithReason:(NSInteger) reason andRoomNo:(NSString*)roomNo;

/**
 * 解散聊天室回调
 * @param reason 状态值 0:成功
 * @param roomNo 房间号
 */
- (void) onChatroomDismissWithReason:(NSInteger) reason andRoomNo:(NSString*) roomNo;

/**
 * 移除成员
 * @param reason 状态值 0:成功
 * @param member 成员号
 */
- (void) onChatroomRemoveMemberWithReason:(NSInteger) reason andMember:(NSString*) member;

/********************多媒体IM的方法********************/
// 录音超时
-(void)onRecordingTimeOut:(long) ms;
//通知客户端当前录音振幅
-(void)onRecordingAmplitude:(double) amplitude;
//播放结束
-(void)onFinishedPlaying;
//发送多媒体IM结果回调
- (void) onSendInstanceMessageWithReason: (NSInteger) reason andMsg:(InstanceMsg*) data;
// 下载文件回调
- (void)onDownloadAttachedWithReason:(NSInteger)reason andFileName:(NSString*) fileName;
//通知客户端收到新的信息
- (void)onReceiveInstanceMessage:(InstanceMsg*) msg;
//确认已下载
- (void)onConfirmInstanceMessageWithReason:(NSInteger)reason;
@end

#endif
