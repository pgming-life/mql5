// Forward Define (前方定義)

#ifndef ___FWDEF_MQH___
#define ___FWDEF_MQH___

// エラー処理の可否
//#define ERRORSTOP_OK

#ifdef ERRORSTOP_OK
// 存在しないDLLから存在しない関数を宣言(エラー取得のためのダミー関数)
#import "dummy.dll"
    void INDICATOR_STOP();
#import
#endif

#endif  // ___FWDEF_MQH___
