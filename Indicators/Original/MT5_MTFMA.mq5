#include <Original/Mql5_MovingAverages.mqh>
#include <Original/Mql4_5_MultiTimeframe.mqh>

#property copyright "Copyright (c) 2020, pgming"
#property link "https://pgming-ctrl.com"
#property description "マルチタイムフレームの3つの移動平均線を描画するインディケータ"

#property strict                            // 厳格なコンパイルモード用のコンパイラ指令
#property indicator_chart_window            // メインウィンドウ指定
#property indicator_buffers 3               // インディケータバッファ数
#property indicator_plots   3               // プロットバッファ数

// 各インディケータの初期設定(パラメータと紐づいている)
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_color1  clrMagenta
#property indicator_color2  clrAqua
#property indicator_color3  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID

// インスタンスの生成
Mql5MovingAverages* ma1;
Mql5MovingAverages* ma2;
Mql5MovingAverages* ma3;

// パラメータ
input ENUM_MA_METHOD    i_ma1Method = MODE_SMA;     // MA1-モード
input int               i_ma1Period = 20;           // MA1-期間
input int               i_ma1Shift  = 0;            // MA1-シフト
input color             i_ma1Color  = clrMagenta;   // MA1-カラー
input ENUM_LINE_STYLE   i_ma1Style  = STYLE_SOLID;  // MA1-スタイル
input int               i_ma1Width  = 1;            // MA1-太さ
input bool              i_showMA2   = true;         // MA2-描画有無
input color             i_ma2Color  = clrAqua;      // MA2-カラー
input bool              i_showMA3   = true;         // MA3-描画有無
input color             i_ma3Color  = clrLime;      // MA3-カラー

// 初期化
int OnInit()
{
    // 指標値の精度を設定
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    
    // インスタンス初期化
    ma1 = new Mql5MovingAverages(0, i_ma1Method, i_ma1Period, i_ma1Shift, i_ma1Color, i_ma1Style, i_ma1Width);
    ma2 = new Mql5MovingAverages(1, i_ma1Method, MTF1(i_ma1Period), MTF1(i_ma1Shift), i_ma2Color, i_ma1Style, i_ma1Width);
    ma3 = new Mql5MovingAverages(2, i_ma1Method, MTF2(i_ma1Period), MTF2(i_ma1Shift), i_ma3Color, i_ma1Style, i_ma1Width);
    
    // 成功結果を返す
    return INIT_SUCCEEDED;
}

// 終了時処理
void OnDeinit(const int reason)
{
    delete(ma1);
    delete(ma2);
    delete(ma3);
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
    // MTFMAを描画
    if(i_showMA3)
    {
        // 月足ではないとき
        if(PeriodSeconds(Period()) / 60 != 43200)
        {
            ma3.DrawMql5MA(false, i_ma1Method, MTF2(i_ma1Period), rates_total, prev_calculated, close);
        }
        else
        {
            ma3.ClearPlotBuffer();
        }
    }
    else ma3.ClearPlotBuffer();
    if(i_showMA2) ma2.DrawMql5MA(false, i_ma1Method, MTF1(i_ma1Period), rates_total, prev_calculated, close);
    else ma2.ClearPlotBuffer();
    ma1.DrawMql5MA(false, i_ma1Method, i_ma1Period, rates_total, prev_calculated, close);
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
