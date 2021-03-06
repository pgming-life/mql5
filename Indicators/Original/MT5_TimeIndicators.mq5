#include <Original/Mql4_5_TimeIndicators.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "ブローカー時間(ロシア時間)とコンピュータ時間(日本時間)を表示するインジケータ"

#property strict                            // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_chart_window            // メインウィンドウ指定
#property indicator_plots 0                 // プロップバッファ0

// ウィンドウ種別
enum WindowIndex
{
    MAIN_WINDOW = 0,
    SUB1_WINDOW,
    SUB2_WINDOW,
    SUB3_WINDOW,
};

// パラメータ
input color i_btColor = White;          // ブローカータイムカラー
input color i_ctColor = Aquamarine;     // コンピュータタイムカラー

// 初期化
int OnInit()
{
    // 成功結果を返す
    return INIT_SUCCEEDED;
}

// 終了時処理
void OnDeinit(const int reason)
{
    DeleteTimeObject(MAIN_WINDOW);
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
    // タイムインジケータを描画
    DrawTimeIndicators(MAIN_WINDOW, i_btColor, i_ctColor);
    
    return 0;
}
