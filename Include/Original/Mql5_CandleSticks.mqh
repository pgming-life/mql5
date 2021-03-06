#ifndef ___MQL5_CANDLESTICKS_MQH___
#define ___MQL5_CANDLESTICKS_MQH___

#include <Original/FwDef.mqh>

class Mql5CandleSticks
{
public:
    // コンストラクタ
    Mql5CandleSticks(
        int fourPlotIndex,          // プロットバッファインデックスの始めの番号
        bool flagColor=false,       // カラー判定
        color outLinesAndBar=White, // アウトライン&バーのカラー
        color upBody=Red,           // 陽線ボディのカラー
        color dnBody=Blue           // 陰線ボディのカラー
        )
    {
        // インディケータ名
        string short_name = _Symbol + "," + ConvPeriodString(PeriodSeconds(Period()) / 60) + " ";
        IndicatorSetString(INDICATOR_SHORTNAME, short_name);
        // _PeriodだとMT5のH1以上の期間がバグっているためPeriodSecondsで代用。
        
        // メインウィンドウのローソク足情報を取得
        if(!flagColor)
        {
            outLinesAndBar    = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);
            upBody            = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
            dnBody            = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
        }
        
        // インディケータバッファのインデックスを設定
        SetIndexBuffer(fourPlotIndex, m_openBuffer, INDICATOR_DATA);
        SetIndexBuffer(fourPlotIndex + 1, m_highBuffer, INDICATOR_DATA);
        SetIndexBuffer(fourPlotIndex + 2, m_lowBuffer, INDICATOR_DATA);
        SetIndexBuffer(fourPlotIndex + 3, m_closeBuffer, INDICATOR_DATA);
        
        // インディケータスタイル
        PlotIndexSetInteger(fourPlotIndex, PLOT_COLOR_INDEXES, 3);
        PlotIndexSetInteger(fourPlotIndex, PLOT_LINE_COLOR, 0, outLinesAndBar);
        PlotIndexSetInteger(fourPlotIndex, PLOT_LINE_COLOR, 1, upBody);
        PlotIndexSetInteger(fourPlotIndex, PLOT_LINE_COLOR, 2, dnBody);
    }
    
    // デストラクタ
    ~Mql5CandleSticks()
    {
        // バッファ初期化
        ArrayInitialize(m_openBuffer, EMPTY_VALUE);
        ArrayInitialize(m_highBuffer, EMPTY_VALUE);
        ArrayInitialize(m_lowBuffer, EMPTY_VALUE);
        ArrayInitialize(m_closeBuffer, EMPTY_VALUE);
    }
    
    // MT5のローソク足描画
    void DrawMql5CandleSticks(
        bool mirrorFlag,        // チャート反転判定
        bool clearFlag,         // バッファクリア判定
        int rates_total,        // 現在チャートで表示されているバーのトータル数(インデックス数)
        int begin,              // 描画をスタートさせるインデックス番号
        const double &open[],   // 始値定数バッファ
        const double &high[],   // 高値定数バッファ
        const double &low[],    // 安値定数バッファ
        const double &close[],  // 終値定数バッファ
        double highestPrice=0   // 最も高い価格(2020現在一番価格が高い金融商品はUS30になる)
        )
    {
        // バッファクリア判定
        if(clearFlag)
        {
            // バッファ初期化
            ArrayInitialize(m_openBuffer, EMPTY_VALUE);
            ArrayInitialize(m_highBuffer, EMPTY_VALUE);
            ArrayInitialize(m_lowBuffer, EMPTY_VALUE);
            ArrayInitialize(m_closeBuffer, EMPTY_VALUE);
        }
        else
        {
            if(begin == rates_total)
            {
                // 2回目以降の描画は当該足だけを計算
                begin = rates_total - 1;
            }
            else
            {
                // 足の更新時に0から再計算
                begin = 0;
            }
        }
        
        // ローソク足を描画
        if(mirrorFlag)
        {
            for(int i = begin; i < rates_total; i++)
            {
                m_openBuffer[i]     = -open[i] + highestPrice;
                m_highBuffer[i]     = -high[i] + highestPrice;
                m_lowBuffer[i]      = -low[i] + highestPrice;
                m_closeBuffer[i]    = -close[i] + highestPrice;
            }
        }
        else
        {
            for(int i = begin; i < rates_total; i++)
            {
                m_openBuffer[i]     = open[i];
                m_highBuffer[i]     = high[i];
                m_lowBuffer[i]      = low[i];
                m_closeBuffer[i]    = close[i];
            }
        }
    }
    
private:
    // int期間を文字列に変換
    string ConvPeriodString(int timeframe)
    {
        switch(timeframe) {
            case 1:     return "M1";
            case 5:     return "M5";
            case 15:    return "M15";
            case 60:    return "H1";
            case 240:   return "H4";
            case 1440:  return "Daily";
            case 10080: return "Weekly";
            case 43200: return "Monthly";
            default:    return (string)timeframe;   // そのまま返す
        }
    }
    
    // 変数宣言
    double m_openBuffer[];      // 始値プロットバッファ
    double m_highBuffer[];      // 高値プロットバッファ
    double m_lowBuffer[];       // 安値プロットバッファ
    double m_closeBuffer[];     // 終値プロットバッファ
};

#endif  // ___MQL5_CANDLESTICKS_MQH___
