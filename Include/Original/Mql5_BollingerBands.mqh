#ifndef ___MQL5_BOLLINGERBANDS_MQH___
#define ___MQL5_BOLLINGERBANDS_MQH___

#include <Original/FwDef.mqh>
#include <MovingAverages.mqh>

class Mql5BollingerBands
{
public:
    // コンストラクタ
    Mql5BollingerBands(
        int fivePlotIndex,
        int calcIndex,
        int period,
        int shift,
        color middleColor,
        color bands1Color,
        color bands2Color,
        ENUM_LINE_STYLE middleStyle,
        ENUM_LINE_STYLE bands1Style,
        ENUM_LINE_STYLE bands2Style,
        int middleWidth,
        int bands1Width,
        int bands2Width,
        double dev1=2.0,
        double dev2=3.0
        ) : 
        m_dev1(dev1),
        m_dev2(dev2)
    {
        // MA描画始点
        int drawBegin = period - 1;
        
        // インディケータバッファのインデックスを設定
        SetIndexBuffer(fivePlotIndex, m_middleBuffer, INDICATOR_DATA);
        SetIndexBuffer(fivePlotIndex + 1, m_upper1Buffer, INDICATOR_DATA);
        SetIndexBuffer(fivePlotIndex + 2, m_lower1Buffer, INDICATOR_DATA);
        SetIndexBuffer(fivePlotIndex + 3, m_upper2Buffer, INDICATOR_DATA);
        SetIndexBuffer(fivePlotIndex + 4, m_lower2Buffer, INDICATOR_DATA);
        SetIndexBuffer(calcIndex, m_stdDevBuffer, INDICATOR_CALCULATIONS);
        
        // インディケータラベル
        PlotIndexSetString(fivePlotIndex, PLOT_LABEL, "Bands(" + string(period) + ") Middle");
        PlotIndexSetString(fivePlotIndex + 1, PLOT_LABEL, "Bands(" + string(period) + ") Upper1");
        PlotIndexSetString(fivePlotIndex + 2, PLOT_LABEL, "Bands(" + string(period) + ") Lower1");
        PlotIndexSetString(fivePlotIndex + 3, PLOT_LABEL, "Bands(" + string(period) + ") Upper2");
        PlotIndexSetString(fivePlotIndex + 4, PLOT_LABEL, "Bands(" + string(period) + ") Lower2");
        
        // インディケータスタイル
        PlotIndexSetInteger(fivePlotIndex, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(fivePlotIndex, PLOT_SHIFT, shift);
        PlotIndexSetInteger(fivePlotIndex, PLOT_LINE_COLOR, middleColor);
        PlotIndexSetInteger(fivePlotIndex, PLOT_LINE_STYLE, middleStyle);
        PlotIndexSetInteger(fivePlotIndex, PLOT_LINE_WIDTH, middleWidth);
        PlotIndexSetInteger(fivePlotIndex + 1, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(fivePlotIndex + 1, PLOT_SHIFT, shift);
        PlotIndexSetInteger(fivePlotIndex + 1, PLOT_LINE_COLOR, bands1Color);
        PlotIndexSetInteger(fivePlotIndex + 1, PLOT_LINE_STYLE, bands1Style);
        PlotIndexSetInteger(fivePlotIndex + 1, PLOT_LINE_WIDTH, bands1Width);
        PlotIndexSetInteger(fivePlotIndex + 2, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(fivePlotIndex + 2, PLOT_SHIFT, shift);
        PlotIndexSetInteger(fivePlotIndex + 2, PLOT_LINE_COLOR, bands1Color);
        PlotIndexSetInteger(fivePlotIndex + 2, PLOT_LINE_STYLE, bands1Style);
        PlotIndexSetInteger(fivePlotIndex + 2, PLOT_LINE_WIDTH, bands1Width);
        PlotIndexSetInteger(fivePlotIndex + 3, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(fivePlotIndex + 3, PLOT_SHIFT, shift);
        PlotIndexSetInteger(fivePlotIndex + 3, PLOT_LINE_COLOR, bands2Color);
        PlotIndexSetInteger(fivePlotIndex + 3, PLOT_LINE_STYLE, bands2Style);
        PlotIndexSetInteger(fivePlotIndex + 3, PLOT_LINE_WIDTH, bands2Width);
        PlotIndexSetInteger(fivePlotIndex + 4, PLOT_DRAW_BEGIN, drawBegin);
        PlotIndexSetInteger(fivePlotIndex + 4, PLOT_SHIFT, shift);
        PlotIndexSetInteger(fivePlotIndex + 4, PLOT_LINE_COLOR, bands2Color);
        PlotIndexSetInteger(fivePlotIndex + 4, PLOT_LINE_STYLE, bands2Style);
        PlotIndexSetInteger(fivePlotIndex + 4, PLOT_LINE_WIDTH, bands2Width);
    }
    
    // デストラクタ
    ~Mql5BollingerBands()
    {
        // バッファ初期化
        ArrayInitialize(m_middleBuffer, EMPTY_VALUE);
        ArrayInitialize(m_upper1Buffer, EMPTY_VALUE);
        ArrayInitialize(m_lower1Buffer, EMPTY_VALUE);
        ArrayInitialize(m_upper2Buffer, EMPTY_VALUE);
        ArrayInitialize(m_lower2Buffer, EMPTY_VALUE);
        ArrayInitialize(m_stdDevBuffer, 0.0);
    }
    
    // MT5のボリンジャーバンド描画
    void DrawMql5BollingerBands(
        bool showMiddle,
        bool showBands1,
        bool showBands2,
        bool clearFlag,
        int period,
        int rates_total,
        int begin,
        const double &close[]
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
            ArrayInitialize(m_middleBuffer, EMPTY_VALUE);
            ArrayInitialize(m_upper1Buffer, EMPTY_VALUE);
            ArrayInitialize(m_lower1Buffer, EMPTY_VALUE);
            ArrayInitialize(m_upper2Buffer, EMPTY_VALUE);
            ArrayInitialize(m_lower2Buffer, EMPTY_VALUE);
            ArrayInitialize(m_stdDevBuffer, 0.0);
        }
        else
        {
            // 足の更新時に0から再計算
            if(begin != rates_total) begin = 0;
        }
        
        // ボリンジャーバンドを描画
        for(int i = begin; i < rates_total && !IsStopped(); i++)
        {
            m_middleBuffer[i] = SimpleMA(i, period, close);
            m_stdDevBuffer[i] = StdDev(i, period, m_middleBuffer, close);
            m_upper1Buffer[i] = showBands1 ? m_middleBuffer[i] + m_dev1 * m_stdDevBuffer[i] : EMPTY_VALUE;
            m_lower1Buffer[i] = showBands1 ? m_middleBuffer[i] - m_dev1 * m_stdDevBuffer[i] : EMPTY_VALUE;
            m_upper2Buffer[i] = showBands2 ? m_middleBuffer[i] + m_dev2 * m_stdDevBuffer[i] : EMPTY_VALUE;
            m_lower2Buffer[i] = showBands2 ? m_middleBuffer[i] - m_dev2 * m_stdDevBuffer[i] : EMPTY_VALUE;
            if(!showMiddle) m_middleBuffer[i] = EMPTY_VALUE;
        }
    }
    
    // BBプロットバッファクリア
    inline void ClearPlotBuffer()
    {
        // プロットバッファをEMPTY_VALUEで初期化
        ArrayInitialize(m_middleBuffer, EMPTY_VALUE);
        ArrayInitialize(m_upper1Buffer, EMPTY_VALUE);
        ArrayInitialize(m_lower1Buffer, EMPTY_VALUE);
        ArrayInitialize(m_upper2Buffer, EMPTY_VALUE);
        ArrayInitialize(m_lower2Buffer, EMPTY_VALUE);
    }
    // DrawMql5BollingerBands関数を呼ばずに
    // ボリンジャーバンドそのものを描画しない場合は、
    // プロットバッファに0.0が入ったままなので価格0に対して描画されることになるため、
    // このクリア関数で描画しないようにする必要がある。
    
private:
    //　標準偏差計算
    double StdDev(
        int position,
        int period,
        const double &MAprice[],
        const double &close[]
        )
    {
        double stdDev = 0.0;
        
        if(position < period) return(stdDev);
        
        for(int i = 0; i < period; i++)
            stdDev += MathPow(close[position - i] - MAprice[position], 2);
        
        stdDev = MathSqrt(stdDev / period);
        
        return(stdDev);
    }
    
    // 変数宣言
    double m_middleBuffer[];    // ミドルラインプロットバッファ
    double m_upper1Buffer[];    // 偏差上方ライン1プロットバッファ
    double m_lower1Buffer[];    // 偏差下方ライン1プロットバッファ
    double m_upper2Buffer[];    // 偏差上方ライン2プロットバッファ
    double m_lower2Buffer[];    // 偏差下方ライン2プロットバッファ
    double m_stdDevBuffer[];    // 標準偏差計算用バッファ
    double m_dev1;              // 標準偏差段階1
    double m_dev2;              // 標準偏差段階2
};

#endif  // ___MQL5_BOLLINGERBANDS_MQH___
