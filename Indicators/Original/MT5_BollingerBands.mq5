#include <Original/Mql5_BollingerBands.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "ボリンジャーバンドを描画するインディケータ"

#property strict                            // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_chart_window            // メインウィンドウ指定
#property indicator_buffers 6               // インディケータバッファ数
#property indicator_plots   5               // プロットバッファ数

// 各インディケータバッファの初期設定(パラメータと紐づいている)
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrDodgerBlue
#property indicator_color4  clrBlue
#property indicator_color5  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID
#property indicator_style5  STYLE_SOLID

// インスタンスの生成
Mql5BollingerBands* bb;

// パラメータ
input bool              i_showMiddle    = true;             // ミドル-描画有無
input bool              i_showBands1    = true;             // バンド1-描画有無
input bool              i_showBands2    = true;             // バンド2-描画有無
input int               i_period        = 20;               // 期間
input int               i_shift         = 0;                // シフト
input color             i_middleColor   = clrAqua;          // ミドル-カラー
input color             i_bands1Color   = clrDodgerBlue;    // バンド1-カラー
input color             i_bands2Color   = clrBlue;          // バンド2-カラー
input ENUM_LINE_STYLE   i_middleStyle   = STYLE_SOLID;      // ミドル-スタイル
input ENUM_LINE_STYLE   i_bands1Style   = STYLE_SOLID;      // バンド1-スタイル
input ENUM_LINE_STYLE   i_bands2Style   = STYLE_SOLID;      // バンド2-スタイル
input int               i_middleWidth   = 1;                // ミドル-太さ
input int               i_bands1Width   = 1;                // バンド1-太さ
input int               i_bands2Width   = 1;                // バンド2-太さ
input double            i_dev1          = 2.0;              // 標準偏差段階1
input double            i_dev2          = 3.0;              // 標準偏差段階2

// 初期化
int OnInit()
{
    // 指標値の精度を設定
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // インスタンス初期化
    bb = new Mql5BollingerBands(
        0,
        5,
        i_period,
        i_shift,
        i_middleColor,
        i_bands1Color,
        i_bands2Color,
        i_middleStyle,
        i_bands1Style,
        i_bands2Style,
        i_middleWidth,
        i_bands1Width,
        i_bands2Width,
        i_dev1,
        i_dev2
        );
    
    // 成功結果を返す
    return INIT_SUCCEEDED;
}

// 終了時処理
void OnDeinit(const int reason)
{
    delete(bb);
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
    // ボリンジャーバンドを描画
    bb.DrawMql5BollingerBands(i_showMiddle, i_showBands1, i_showBands2, false, i_period, rates_total, prev_calculated, close);
    // バッファクリアフラグをfalseにすることでprev_calculatedを使えるようになる。
    // これで不要な描画処理が減る。
    // MT5チャートにおけるインデックスは「最左端(チャートの始め)から最右端(当該)まで」が「0からrates_totalsまで」になっている。
    // この0がprev_calculatedになることによって、1回目の処理が0で2回目以降はrates_totalになる。
    // なので、2回目ループ以降は描画処理をしない。足の更新時だけ処理が走ることになる。
    // 当該インデックスの価格を随時参照しないため、急激な動きでも当該のMAにブレはないのでトレードする上での目線もブレないようになる。
    // バッファクリアフラグがtrueの場合は、バッファがクリアされ、毎描画beginからrates_totalまで計算する。
    // MT4はチャートのインデックスが逆で当該が0になる。
    // 基本的にMT4もMT5もどちらも0から描画する処理傾向にある。(人によって違うが、コード上でそうしている傾向にあるということ。)
    
    return rates_total;
    // rates_totalを返すことでこれがprev_calculatedになる。
}
