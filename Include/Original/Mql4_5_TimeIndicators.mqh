#ifndef ___MQL4_5_TIMEINDICATORS_MQH___
#define ___MQL4_5_TIMEINDICATORS_MQH___

#include <Original/FwDef.mqh>

// 固定グローバル変数
static const string g_prefix = "time_";
static const string g_font = "Arial";
static const int g_fontSize = 12;

// タイムインジケータの描画
void DrawTimeIndicators(
    int windowIndex,        // ウィンドウインデックス(0:メインウィンドウ, 1:サブ1ウィンドウ, 2:サブ2ウィンドウ, ・・・)
    color btColor,          // ブローカータイムの色
    color ctColor,          // コンピュータタイムの色
    int bottomRight=150,    // 右下からの距離
    double zoomLevel=1.2    // ズーム倍率
    )
{
    CreateBrokerTimeText(windowIndex, btColor, bottomRight, zoomLevel);
    CreateBrokerTime(windowIndex, btColor, bottomRight, zoomLevel);
    CreateComputerTimeText(windowIndex, ctColor, bottomRight, zoomLevel);
    CreateComputerTime(windowIndex, ctColor, bottomRight, zoomLevel);
}

// BrokerTimeテキストオブジェクトの作成
void CreateBrokerTimeText(int windowIndex, color btColor, int bottomRight, double zoomLevel)
{
    string btText = "B r o k e r T i m e :";
    
    if(!ObjectCreate(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJ_LABEL, windowIndex, 0, 0))
    {
        // エラー処理
#ifdef ERRORSTOP_OK
        Alert("BrokerTimeオブジェクトの作成に失敗しました。");
        INDICATOR_STOP();
#endif
    }
    
    ObjectSetInteger(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
    ObjectSetInteger(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_XDISTANCE, bottomRight * zoomLevel);
    ObjectSetInteger(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_YDISTANCE, 70 * zoomLevel);
    ObjectSetString(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_TEXT, btText);
    ObjectSetString(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_FONT, g_font);
    ObjectSetInteger(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_FONTSIZE, 8 * zoomLevel);
    ObjectSetInteger(0, g_prefix + "BrokerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_COLOR, btColor);
}

// ブローカータイムオブジェクトの作成
void CreateBrokerTime(int windowIndex, color btColor, int bottomRight, double zoomLevel)
{
    string bt  = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
    
    if(!ObjectCreate(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJ_LABEL, windowIndex, 0, 0))
    {
        // エラー処理
#ifdef ERRORSTOP_OK
        Alert("ブローカータイムの時間オブジェクトの作成に失敗しました。");
        INDICATOR_STOP();
#endif
    }
    
    ObjectSetInteger(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
    ObjectSetInteger(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_XDISTANCE, bottomRight * zoomLevel);
    ObjectSetInteger(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_YDISTANCE, 60 * zoomLevel);
    ObjectSetString(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_TEXT, bt);
    ObjectSetString(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_FONT, g_font);
    ObjectSetInteger(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_FONTSIZE, g_fontSize * zoomLevel);
    ObjectSetInteger(0, g_prefix + "BrokerTime:WindowIndex" + (string)windowIndex, OBJPROP_COLOR, btColor);
}

// ComputerTimeテキストオブジェクトの作成
void CreateComputerTimeText(int windowIndex, color ctColor, int bottomRight, double zoomLevel)
{
    string ctText = "C o m p u t e r T i m e :";
    
    if(!ObjectCreate(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJ_LABEL, windowIndex, 0, 0))
    {
        // エラー処理
#ifdef ERRORSTOP_OK
        Alert("ComputerTimeオブジェクトの作成に失敗しました。");
        INDICATOR_STOP();
#endif
    }
    
    ObjectSetInteger(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
    ObjectSetInteger(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_XDISTANCE, bottomRight * zoomLevel);
    ObjectSetInteger(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_YDISTANCE, 40 * zoomLevel);
    ObjectSetString(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_TEXT, ctText);
    ObjectSetString(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_FONT, g_font);
    ObjectSetInteger(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_FONTSIZE, 8 * zoomLevel);
    ObjectSetInteger(0, g_prefix + "ComputerTimeText:WindowIndex" + (string)windowIndex, OBJPROP_COLOR, ctColor);
}

// コンピュータタイムオブジェクトの作成
void CreateComputerTime(int windowIndex, color ctColor, int bottomRight, double zoomLevel)
{
    string ct  = TimeToString(TimeLocal(), TIME_DATE | TIME_SECONDS);
    
    if(!ObjectCreate(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJ_LABEL, windowIndex, 0, 0))
    {
        // エラー処理
#ifdef ERRORSTOP_OK
        Alert("コンピュータタイムの時間オブジェクトの作成に失敗しました。");
        INDICATOR_STOP();
#endif
    }
    
    ObjectSetInteger(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
    ObjectSetInteger(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_XDISTANCE, bottomRight * zoomLevel);
    ObjectSetInteger(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_YDISTANCE, 30 * zoomLevel);
    ObjectSetString(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_TEXT, ct);
    ObjectSetString(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_FONT, g_font);
    ObjectSetInteger(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_FONTSIZE, g_fontSize * zoomLevel);
    ObjectSetInteger(0, g_prefix + "ComputerTime:WindowIndex" + (string)windowIndex, OBJPROP_COLOR, ctColor);
}

// タイムオブジェクトの削除
void DeleteTimeObject(int windowIndex)
{
    ObjectsDeleteAll(0, g_prefix, windowIndex);
    ChartRedraw();
}

#endif  // ___MQL4_5_TIMEINDICATORS_MQH___
