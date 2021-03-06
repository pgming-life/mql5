#include <Original/Mql5_CandleSticks.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "メインウィンドウに反転したローソク足を描画するインディケータ"

#property strict                        // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_chart_window        // メインウィンドウ指定
#property indicator_buffers 8           // インディケータバッファ数
#property indicator_plots   4           // プロットバッファ数

// インディケータの初期設定
#property indicator_type1   DRAW_CANDLES
#property indicator_label1  "CandleSticks"

// グローバル変数
static int g_bugShowBars = 173;
static double g_mirrorOpenBuffer[];     // 始値反転バッファ
static double g_mirrorHighBuffer[];     // 高値反転バッファ
static double g_mirrorLowBuffer[];      // 安値反転バッファ
static double g_mirrorCloseBuffer[];    // 終値反転バッファ

// インスタンスの生成
Mql5CandleSticks* cs;

// 初期化
int OnInit()
{
    // 指標値の精度を設定    
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // インスタンス初期化
    cs = new Mql5CandleSticks(0, true, Yellow, Red, Blue);
    
    // インディケータバッファのインデックスを設定
    SetIndexBuffer(4, g_mirrorOpenBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, g_mirrorHighBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(6, g_mirrorLowBuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(7, g_mirrorCloseBuffer, INDICATOR_CALCULATIONS);
    
    // 成功結果を返す
    return INIT_SUCCEEDED;
}

// 終了時処理
void OnDeinit(const int reason)
{
    delete(cs);
}

// 描画
int OnCalculate(
    const int rates_total,      // チャートで表示されているバーのトータル数(インデックス数)
    const int prev_calculated,  // 前の呼び出しでのOnCalculate()の実行の結果(例えば、現在の値 rates_total = 1000 でprev_calculated = 999、各指標バッファでこの1つの値の計算を行うだけでよい)
    const datetime &time[],     // 時間定数バッファ
    const double &open[],       // 始値定数バッファ
    const double &high[],       // 高値定数バッファ
    const double &low[],        // 安値定数バッファ
    const double &close[],      // 終値定数バッファ
    const long &tick_volume[],  // ティックボリューム定数バッファ
    const long &volume[],       // 出来高定数バッファ
    const int &spread[]         // スプレッド定数バッファ
    )
{
    // チャートウィンドウ幅を取得
    int firstVisibleIndex = ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);                    // 左端
    int lastVisibleIndex  = firstVisibleIndex - ChartGetInteger(0, CHART_VISIBLE_BARS);     // 右端
    // CHART_FIRST_VISIBLE_BARは新しくチャートを表示するときにデータを読み込めないバグあり。
    // バグ発生時、firstVisibleIndex = 0となる。
    // CHART_VISIBLE_BARSも同様にバグあり。
    // バグ発生時、ChartGetInteger(0, CHART_VISIBLE_BARS) = 0となる。
    
    /*
    Print("firstVisibleIndex : ", firstVisibleIndex);
    Print("CHART_VISIBLE_BARS : ", ChartGetInteger(0, CHART_VISIBLE_BARS));
    Print("lastVisibleIndex : ", lastVisibleIndex);
    */
    
    // バグ発生時の修正
    if(lastVisibleIndex <= 0) { // CHART_VISIBLE_BARSがチャート表示のバグで機能しないときのためにゼロを含む。
        lastVisibleIndex = rates_total;
        //Print("lastVisibleIndex = rates_total");
    }
    else {
        lastVisibleIndex = rates_total - lastVisibleIndex;
        //Print("lastVisibleIndex = rates_total - lastVisibleIndex");
    }
    firstVisibleIndex = rates_total - firstVisibleIndex;
    
    // 両端でのインデックス調整
    if(lastVisibleIndex <= g_bugShowBars)   // バグ用チャート幅MAX173
    {
        // 現在のオリジナルのチャート幅に合わせているので、MAX173[左端の半分見えているバーを含まない]のバー数となる。（ローソク足の拡大縮小が普通の基準に設定されていることを前提としている）
        firstVisibleIndex = 1;
    }
    else if(firstVisibleIndex == rates_total)
    {
        // 現在のオリジナルのチャート幅に合わせたバー数(173)にしているが、価格の変化が処理されるときに直ぐにChartGetInteger(0, CHART_FIRST_VISIBLE_BAR)に上書きされるため視覚的問題はない。
        firstVisibleIndex = rates_total - g_bugShowBars;
    }
    
    // チャート幅における価格反転加工処理
    double halfLine = GetHigh(lastVisibleIndex - 1, firstVisibleIndex, high) - ((GetHigh(lastVisibleIndex - 1, firstVisibleIndex, high) - GetLow(lastVisibleIndex - 1, firstVisibleIndex, low)) / 2);
    for(int i = firstVisibleIndex; i < lastVisibleIndex; i++)
    {
        // 最高値と最安値の中間価格を基準に反転
        if(open[i] > halfLine) g_mirrorOpenBuffer[i]    = halfLine - (open[i] - halfLine);
        if(open[i] < halfLine) g_mirrorOpenBuffer[i]    = halfLine + (halfLine - open[i]);
        if(open[i] == halfLine) g_mirrorOpenBuffer[i]   = halfLine;
        if(low[i] > halfLine) g_mirrorHighBuffer[i]     = halfLine - (low[i] - halfLine);
        if(low[i] < halfLine) g_mirrorHighBuffer[i]     = halfLine + (halfLine - low[i]);
        if(low[i] == halfLine) g_mirrorHighBuffer[i]    = halfLine;
        if(high[i] > halfLine) g_mirrorLowBuffer[i]     = halfLine - (high[i] - halfLine);
        if(high[i] < halfLine) g_mirrorLowBuffer[i]     = halfLine + (halfLine - high[i]);
        if(high[i] == halfLine) g_mirrorLowBuffer[i]    = halfLine;
        if(close[i] > halfLine) g_mirrorCloseBuffer[i]  = halfLine - (close[i] - halfLine);
        if(close[i] < halfLine) g_mirrorCloseBuffer[i]  = halfLine + (halfLine - close[i]);
        if(close[i] == halfLine) g_mirrorCloseBuffer[i] = halfLine;
    }
    
    // ローソク足を描画
    cs.DrawMql5CandleSticks(false, true, lastVisibleIndex, firstVisibleIndex, g_mirrorOpenBuffer, g_mirrorHighBuffer, g_mirrorLowBuffer, g_mirrorCloseBuffer);
    
    return rates_total;
    // rates_totalを返すことでこれがprev_calculatedになる。
}

// 開始位置から終了位置までの範囲における最高値取得
double GetHigh(
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
double GetLow(
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
