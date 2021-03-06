#ifndef ___MQL4_5_MULTITIMEFRAME_MQH___
#define ___MQL4_5_MULTITIMEFRAME_MQH___

// 1段階上位の期間を取得
int MTF1(int period)
{
    switch(PeriodSeconds(Period()) / 60)
    {
        case 1:     return period * 5;                                  // M1
        case 5:     return period * 3;                                  // M5
        case 15:    return period * 4;                                  // M15
        case 60:    return period * 4;                                  // H1
        case 240:   return period * 6;                                  // H4
        case 1440:  return period * 5;                                  // Daily
        case 10080: return (int)NormalizeDouble(period * 4.3333, 0);    // Weakly
        case 43200: return period * 5;                                  // Monthly
        default:    return period;                                      // 保険処理としてそのまま返す
    }
}

// 2段階上位の期間を取得
int MTF2(int period)
{
    switch(PeriodSeconds(Period()) / 60)
    {
        case 1:     return period * 5 * 3;                                  // M1
        case 5:     return period * 3 * 4;                                  // M5
        case 15:    return period * 4 * 4;                                  // M15
        case 60:    return period * 4 * 6;                                  // H1
        case 240:   return period * 6 * 5;                                  // H4
        case 1440:  return (int)NormalizeDouble(period * 5 * 4.3333, 0);    // Daily
        case 10080: return (int)NormalizeDouble(period * 4.3333 * 5, 0);    // Weakly
        default:    return period;                                          // 保険処理としてそのまま返す
    }
}
// 月足はかなりの誤差があるので2段階目のMTFには導入しない。

#endif  // ___MQL4_5_MULTITIMEFRAME_MQH___
