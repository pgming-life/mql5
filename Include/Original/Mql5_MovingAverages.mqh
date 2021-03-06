#ifndef ___MQL5_MOVINGAVERAGES_MQH___
#define ___MQL5_MOVINGAVERAGES_MQH___

#include <Original/FwDef.mqh>

class Mql5MovingAverages
{
public:
    // コンストラクタ
    Mql5MovingAverages(
        int plotIndex,              // プロットバッファインデックス番号
        ENUM_MA_METHOD method,      // MA種別(SMA, EMA, SMMA, LWMA)
        int period,                 // 期間(インデックス数)
        int shift,                  // シフトインデックス数
        color plotColor,            // プロットカラー
        ENUM_LINE_STYLE style,      // ラインのスタイル
        int width                   // ラインの太さ
        )
    {
        // インディケータ名
        string shortName = "Unknown MA" + (string)plotIndex;
        
        // MAのラベル設定
        switch(method)
        {
            case MODE_SMA:
                shortName = "MA:Index" + (string)plotIndex + "-SMA";
                break;
            case MODE_EMA:
                shortName = "MA:Index" + (string)plotIndex + "-EMA";
                break;
            case MODE_SMMA:
                shortName = "MA:Index" + (string)plotIndex + "-SMMA";
                break;
            case MODE_LWMA:
                shortName = "MA:Index" + (string)plotIndex + "-LWMA";
                break;
        }
        
        // MA描画始点
        int drawBegin = period - 1;
        
        // インディケータバッファのインデックスを設定
        SetIndexBuffer(plotIndex, m_maPlotBuffer, INDICATOR_DATA);
        
        // インディケータラベル
        PlotIndexSetString(plotIndex, PLOT_LABEL, shortName + "(" + (string)period + ")");
        
        // インディケータスタイル
        PlotIndexSetInteger(plotIndex, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(plotIndex, PLOT_SHIFT, shift);
        PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor);
        PlotIndexSetInteger(plotIndex, PLOT_LINE_STYLE, style);
        PlotIndexSetInteger(plotIndex, PLOT_LINE_WIDTH, width);
    }
    
    // デストラクタ
    virtual ~Mql5MovingAverages()
    {
        // バッファ初期化
        ArrayInitialize(m_maPlotBuffer, EMPTY_VALUE);
    }
    
    // MT5のMA描画
    void DrawMql5MA(
        bool clearFlag,         // バッファクリア判定
        ENUM_MA_METHOD method,  // MA種別(SMA, EMA, SMMA, LWMA)
        int period,             // 期間(インデックス数)
        int rates_total,        // チャートで表示されているバーのトータル数(インデックス数)
        int begin,              // 描画をスタートさせるインデックス番号
        const double &close[]   // 終値定数バッファ
        )
    {
        // バー数を確認
        if(rates_total < period - 1)
        {
            // エラー処理
#ifdef ERRORSTOP_OK
            Alert("MAの計算に必要なバー数がありません。");
            INDICATOR_STOP();
#endif
        }
        
        // バッファクリア判定
        if(clearFlag)
        {
            // バッファ初期化
            ArrayInitialize(m_maPlotBuffer, EMPTY_VALUE);
        }
        else
        {
            // 足の更新時に0から再計算
            if(begin != rates_total) begin = 0;
        }
        
        // MAを描画
        switch(method)
        {
            case MODE_SMA:   Mql5SMA(period, rates_total, begin, close);     break;
            case MODE_EMA:   Mql5EMA(period, rates_total, begin, close);     break;
            case MODE_SMMA:  Mql5SMMA(period, rates_total, begin, close);    break;
            case MODE_LWMA:  Mql5LWMA(period, rates_total, begin, close);    break;
        }
    }
    
    // MAプロットバッファクリア
    inline void ClearPlotBuffer()
    {
        // プロットバッファをEMPTY_VALUEで初期化
        ArrayInitialize(m_maPlotBuffer, EMPTY_VALUE);
    }
    // DrawMql5MA関数を呼ばずに
    // MAそのものを描画しない場合は、
    // プロットバッファに0.0が入ったままなので価格0に対して描画されることになるため、
    // このクリア関数で描画しないようにする必要がある。

private:
    // MT5のSMA(Simple Moving Average): 単純移動平均線
    void Mql5SMA(
        int period, 
        int rates_total, 
        int begin, 
        const double &close[]
        )
    {
        int i, limit;
        limit = period + begin;
        
        if(limit <= rates_total)
        {
            for(i = begin; i < limit - 1; i++) m_maPlotBuffer[i] = 0.0;
            
            double firstValue = 0;
            
            for(i = begin; i < limit; i++) firstValue += close[i];
            
            firstValue /= period;
            
            m_maPlotBuffer[limit - 1] = firstValue;
            
            for(i = limit; i < rates_total && !IsStopped(); i++)
                m_maPlotBuffer[i] = m_maPlotBuffer[i - 1] + (close[i] - close[i - period]) / period;
        }
    }
    
    // MT5のSMMA(Smoothed Moving Average): 平滑移動平均線
    void Mql5SMMA(
        int period, 
        int rates_total, 
        int begin, 
        const double &close[]
        )
    {
        int i, limit;
        limit = period + begin;
        
        if(limit <= rates_total)
        {
            for(i = begin; i < limit - 1; i++) m_maPlotBuffer[i] = 0.0;
            
            double firstValue = 0;
            
            for(i = begin; i < limit; i++) firstValue += close[i];
            
            firstValue /= period;
            
            m_maPlotBuffer[limit - 1] = firstValue;
            
            for(i = limit; i < rates_total && !IsStopped(); i++)
                m_maPlotBuffer[i] = (m_maPlotBuffer[i - 1] * (period - 1) + close[i]) / period;
        }
    }
    
    // MT5のLWMA(Liner Weighted Moving Average): 線形加重移動平均線
    void Mql5LWMA(
        int period, 
        int rates_total, 
        int begin, 
        const double &close[]
        )
    {
        int i, limit, k;
        int weightSum = 0;
        double sum;
        limit = period + begin;
        
        if(limit <= rates_total)
        {
            for(i = begin; i < limit; i++) m_maPlotBuffer[i] = 0.0;
            
            double firstValue = 0;
            
            for(i = begin; i < limit; i++)
            {
                k = i - begin + 1;
                weightSum += k;
                firstValue += k * close[i];
            }
            
            firstValue /= (double)weightSum;
            
            m_maPlotBuffer[limit - 1] = firstValue;
            
            for(i = limit; i < rates_total && !IsStopped(); i++)
            {
                sum = 0;
                for(int j = 0; j < period; j++) sum += (period - j) * close[i - j];
                m_maPlotBuffer[i] = sum / weightSum;
            }
        }
    }
    
    // MT5のEMA(Exponential Moving Average): 指数平滑移動平均線
    // (EWMA(Exponential Weighted Moving Average): 指数加重移動平均線)
    void Mql5EMA(
        int period, 
        int rates_total, 
        int begin, 
        const double &close[]
        )
    {
        int i, limit;
        double smoothFactor = 2.0 / (1.0 + period);
        limit = period + begin;
        
        if(limit <= rates_total)
        {
            m_maPlotBuffer[begin] = close[begin];
            
            for(i = begin + 1; i < limit; i++)
                m_maPlotBuffer[i] = close[i] * smoothFactor + m_maPlotBuffer[i - 1] * (1.0 - smoothFactor);
            
            for(i = limit; i < rates_total && !IsStopped(); i++)
                m_maPlotBuffer[i] = close[i] * smoothFactor + m_maPlotBuffer[i - 1] * (1.0 - smoothFactor);
        }
    }
    
    // 変数宣言
    double m_maPlotBuffer[];    // MAプロットバッファ
};

#endif  // ___MQL5_MOVINGAVERAGES_MQH___
