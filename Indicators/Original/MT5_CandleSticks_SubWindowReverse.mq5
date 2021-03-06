#include <Original/Mql5_CandleSticks.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "サブウィンドウに反転したローソク足を描画するインディケータ"

#property strict                        // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_separate_window     // サブウィンドウ指定
#property indicator_buffers 4           // インディケータバッファ数
#property indicator_plots   4           // プロットバッファ数

// インディケータの初期設定
#property indicator_type1   DRAW_CANDLES
#property indicator_label1  "CandleSticks"

// インスタンスの生成
Mql5CandleSticks* cs;

// パラメータ
input double i_highestPrice = 35000;        // 一番価格が高いUS30基準としたチャート反転対応の価格

// 初期化
int OnInit()
{
    // 指標値の精度を設定
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // インスタンス初期化
    cs = new Mql5CandleSticks(0);
    
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
    // ローソク足を描画
    cs.DrawMql5CandleSticks(true, false, rates_total, prev_calculated, open, high, low, close, i_highestPrice);
    
    return rates_total;
    // rates_totalを返すことでこれがprev_calculatedになる。
}
