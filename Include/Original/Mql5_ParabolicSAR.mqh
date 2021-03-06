#ifndef ___MQL5_PARABOLICSAR_MQH___
#define ___MQL5_PARABOLICSAR_MQH___

#include <Original/FwDef.mqh>

class Mql5ParabolicSAR
{
public:
    // コンストラクタ
    Mql5ParabolicSAR(
        int plotIndex,      // プロットバッファインデックス番号
        int twoCalcIndex,   // 計算用バッファインデックス番号(2つの内の始めの番号)
        color plotColor,    // プロットカラー
        double sarStep,     // AF初期値
        double sarMaximum   // AF最大値
        ) : 
        m_sarStep(sarStep),
        m_sarMaximum(sarMaximum)
    {
        // インディケータバッファのインデックスを設定
        SetIndexBuffer(plotIndex, m_sarPlotBuffer, INDICATOR_DATA);
        SetIndexBuffer(twoCalcIndex, m_epBuffer, INDICATOR_CALCULATIONS);
        SetIndexBuffer(twoCalcIndex + 1, m_afBuffer, INDICATOR_CALCULATIONS);
        
        // インディケータラベル
        PlotIndexSetString(plotIndex, PLOT_LABEL, "ParabolicSAR:Index" + (string)plotIndex);
        
        // インディケータスタイル
        PlotIndexSetInteger(plotIndex, PLOT_ARROW, 159);
        PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor);
    }
    
    // デストラクタ
    ~Mql5ParabolicSAR()
    {
        // バッファ初期化
        ArrayInitialize(m_sarPlotBuffer, EMPTY_VALUE);
        ArrayInitialize(m_epBuffer, 0.0);
        ArrayInitialize(m_afBuffer, 0.0);
    }
    
    // MT5のパラボリック描画
    void DrawMql5ParabolicSAR(
        bool clearFlag,         // バッファクリア判定
        int rates_total,        // 現在チャートで表示されているバーのトータル数(インデックス数)
        int begin,              // 描画をスタートさせるインデックス番号
        const double &high[],   // 高値定数バッファ
        const double &low[]     // 安値定数バッファ
        )
    {
        bool drawFlag = false;
        
        // バー数を確認
        if(rates_total < 3)
        {
            // エラー処理
#ifdef ERRORSTOP_OK
            Alert("パラボリックの計算に必要なバー数がありません。");
            INDICATOR_STOP();
#endif
        }
        
        // バッファクリア判定
        if(clearFlag)
        {
            // バッファ初期化
            ArrayInitialize(m_sarPlotBuffer, EMPTY_VALUE);
            ArrayInitialize(m_epBuffer, 0.0);
            ArrayInitialize(m_afBuffer, 0.0);
            
            drawFlag = true;
        }
        else
        {
            // 足の更新時に1から再計算
            if(begin != rates_total)
            {
                begin = 1;
                drawFlag = true;
            }
        }
        
        if(drawFlag)
        {
            // 最初のパスでSHORTに設定
            int position                = begin;
            int lastRevPos              = begin - 1;    // 最後の反転位置
            bool directionLong          = false;        // LONG方向判定
            m_afBuffer[begin - 1]       = m_sarStep;
            m_afBuffer[begin]           = m_sarStep;
            m_sarPlotBuffer[begin - 1]  = high[begin - 1];
            m_sarPlotBuffer[begin]      = GetHigh(position, lastRevPos, high);
            m_epBuffer[begin - 1]       = low[position];
            m_epBuffer[begin]           = low[position];
            
            // 処理開始
            for(int i = position; i < rates_total - 1 && !IsStopped(); i++)
            {
                // LONG方向判定
                if(directionLong)
                {
                    if(m_sarPlotBuffer[i] > low[i])
                    {
                        // SHORTに変更
                        directionLong       = false;
                        m_sarPlotBuffer[i]  = GetHigh(i, lastRevPos, high);
                        m_epBuffer[i]       = low[i];
                        lastRevPos          = i;
                        m_afBuffer[i]       = m_sarStep;
                    }
                }
                else
                {
                    if(m_sarPlotBuffer[i] < high[i])
                    {
                        // LONGに変更
                        directionLong       = true;
                        m_sarPlotBuffer[i]  = GetLow(i, lastRevPos, low);
                        m_epBuffer[i]       = high[i];
                        lastRevPos          = i;
                        m_afBuffer[i]       = m_sarStep;
                    }
                }
                // 計算を続行
                if(directionLong)
                {
                    // 更新された高値を確認
                    if(high[i] > m_epBuffer[i - 1] && i != lastRevPos)
                    {
                        m_epBuffer[i] = high[i];
                        m_afBuffer[i] = m_afBuffer[i - 1] + m_sarStep;
                        if(m_afBuffer[i] > m_sarMaximum) m_afBuffer[i] = m_sarMaximum;
                    }
                    else
                    {
                        // 反転していないとき
                        if(i != lastRevPos)
                        {
                            m_afBuffer[i] = m_afBuffer[i - 1];
                            m_epBuffer[i] = m_epBuffer[i - 1];
                        }
                    }
                    
                    // 次のSARを計算
                    m_sarPlotBuffer[i + 1] = m_sarPlotBuffer[i] + m_afBuffer[i] * (m_epBuffer[i] - m_sarPlotBuffer[i]);
                    
                    // SARを確認
                    if(m_sarPlotBuffer[i + 1] > low[i] || m_sarPlotBuffer[i + 1] > low[i - 1])
                        m_sarPlotBuffer[i + 1] = MathMin(low[i], low[i - 1]);
                }
                else
                {
                    // 更新された安値を確認
                    if(low[i] < m_epBuffer[i - 1] && i != lastRevPos)
                    {
                        m_epBuffer[i] = low[i];
                        m_afBuffer[i] = m_afBuffer[i - 1] + m_sarStep;
                        if(m_afBuffer[i] > m_sarMaximum) m_afBuffer[i] = m_sarMaximum;
                    }
                    else
                    {
                        // 反転していないとき
                        if(i != lastRevPos)
                        {
                            m_afBuffer[i] = m_afBuffer[i - 1];
                            m_epBuffer[i] = m_epBuffer[i - 1];
                        }
                    }
                    
                    // 次のSARを計算
                    m_sarPlotBuffer[i + 1] = m_sarPlotBuffer[i] + m_afBuffer[i] * (m_epBuffer[i] - m_sarPlotBuffer[i]);
                    
                    // SARを確認
                    if(m_sarPlotBuffer[i + 1] < high[i] || m_sarPlotBuffer[i + 1] < high[i - 1])
                        m_sarPlotBuffer[i + 1] = MathMax(high[i], high[i - 1]);
                }
            }
        }
    }
    
    // SARプロットバッファクリア
    inline void ClearPlotBuffer()
    {
        // プロットバッファをEMPTY_VALUEで初期化
        ArrayInitialize(m_sarPlotBuffer, EMPTY_VALUE);
    }
    // DrawMql5ParabolicSAR関数を呼ばずに
    // パラボリックそのものを描画しない場合は、
    // プロットバッファに0.0が入ったままなので価格0に対して描画されることになるため、
    // このクリア関数で描画しないようにする必要がある。
    
private:
    // 開始位置から終了位置までの範囲における最高値取得
    inline double GetHigh(
        int position,           // 終了位置(インデックス番号)
        int period,             // 開始位置(インデックス番号)
        const double &high[]    // 高値定数バッファ
        )
    {
        double result = high[period];
        for(int i = period; i <= position; i++)
            if(result < high[i]) result = high[i];
        return result;
    }
    
    // 開始位置から終了位置までの範囲における最安値取得
    inline double GetLow(
        int position,           // 終了位置(インデックス番号)
        int period,             // 開始位置(インデックス番号)
        const double &low[]     // 安値定数バッファ
        )
    {
        double result = low[period];
        for(int i = period; i <= position; i++)
            if(result > low[i]) result = low[i];
        return result;
    }
    
    // 変数宣言
    double m_sarPlotBuffer[];   //　SARプロットバッファ
    double m_epBuffer[];        // 計算バッファ(AF[Acceleration Factor]：加速因子（0.02≦AF≦0.20）パラボリックの感度を決定する。初期値：0.02、終値が高値を更新するたびに、+0.02ずつ加算。)
    double m_afBuffer[];        // 計算バッファ(EP[Extreme Price：極大値]：前日までの最高値・最安値。)
    double m_sarStep;           // AF初期値
    double m_sarMaximum;        // AF最大値
};

#endif  // ___MQL5_PARABOLICSAR_MQH___
