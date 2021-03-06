#include <Original/Mql5_ParabolicSAR.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "パラボリックを描画するインディケータ"

#property strict                            // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_chart_window            // メインウィンドウ指定
#property indicator_buffers 3               // インディケータバッファ数
#property indicator_plots   1               // プロットバッファ数

// 各インディケータの初期設定(ここではカラーのパラメータと紐づいている)
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime

// インスタンスの生成
Mql5ParabolicSAR* sar;

// パラメータ
input color     i_sarColor      = clrLime;      // カラー
input double    i_sarStep       = 0.02;         // AF初期値
input double    i_sarMaximum    = 0.2;          // AF最大値
input string    sarString       = "※加速因子（0.02≦AF≦0.20）パラボリックの感度は初期値：0.02、終値が高値を更新するたびに、+0.02ずつ加算される";

// 初期化
int OnInit()
{
    // 指標値の精度を設定
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // インスタンス初期化
    sar = new Mql5ParabolicSAR(0, 1, i_sarColor, i_sarStep, i_sarMaximum);
    
    // 成功結果を返す
    return(INIT_SUCCEEDED);
}

// 終了時処理
void OnDeinit(const int reason)
{
    delete(sar);
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
    // パラボリックを描画
    sar.DrawMql5ParabolicSAR(false, rates_total, prev_calculated, high, low);
    // バッファクリアフラグをfalseにすることでprev_calculatedを使えるようになる。
    // これで不要な描画処理が減る。
    // MT5チャートにおけるインデックスは「最左端(チャートの始め)から最右端(当該)まで」が「0からrates_totalsまで」になっている。
    // この0がprev_calculatedになることによって、1回目の処理が0で2回目以降はrates_totalになる。(パラボリックの場合は0ではなく1)
    // なので、2回目ループ以降は描画処理をしない。足の更新時だけ処理が走ることになる。
    // バッファクリアフラグがtrueの場合は、バッファがクリアされ、毎描画beginからrates_totalまで計算する。
    // MT4はチャートのインデックスが逆で当該が0になる。
    // 基本的にMT4もMT5もどちらも0から描画する処理傾向にある。(人によって違うが、コード上でそうしている傾向にあるということ。)
    
    return rates_total;
    // rates_totalを返すことでこれがprev_calculatedになる。
}
