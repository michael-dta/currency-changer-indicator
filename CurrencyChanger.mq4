//+------------------------------------------------------------------+
//|                                              CurrencyChanger.mq4 |
//|                                   Michael Douglas Torres Azevedo |
//|                                           michael.dta1@gmail.com |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                  https://github.com/michael-dta/ |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2025, MetaQuotes Ltd."
#property link          "https://github.com/michael-dta/"
#property version       "1.00"
#property description   "CurrencyChanger v1.00"
//
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Constants
//+------------------------------------------------------------------+
#define  PREFFIX_OBJNAME   "CurrChangerV.100"
#define  CURRENCYCOUNT     8
//+------------------------------------------------------------------+
//| Enumerators
//+------------------------------------------------------------------+
enum EnumSteps
{
   ADD_PREFFIX    = 0,
   ADD_SUFFIX     = 1,
   CREATE_BUTTONS = 2
};
//+------------------------------------------------------------------+
//| Inputs
//+------------------------------------------------------------------+
extern   string      inpCurrencies     = "AUD,CAD,CHF,EUR,GBP,JPY,NZD,USD";   // Currencies separated by commas
extern   string      inpPreffix        = "";    // Preffix of each symbol
extern   string      inpSymbols        = "AUDCAD,CADCHF,CHFJPY,EURGBP,GBPCAD,USDJPY,NZDUSD,USDCAD"; // Symbols separated by commas
extern   string      inpSuffix         = "m";   // Suffix of each symbol
extern   int         inpMoveX          = 5;     // Horizontal space in pixels from left side
extern   int         inpMoveY          = 5;     // Vertical space in pixels from top side
extern   int         inpWidth          = 160;   // Button width in pixels
extern   int         inpHeight         = 20;    // Button height in pixels
extern   color       inpNormalBgClr    = clrGainsboro;      // Normal background color
extern   color       inpNormalTxtClr   = clrBlack;          // Normal text color
extern   color       inpNormalBdrClr   = clrDarkGray;       // Normal border color
extern   color       inpSelectedBgClr  = clrBlue;           // Selected background color
extern   color       inpSelectedTxtClr = clrOrange;         // Selected text color
extern   color       inpSelectedBdrClr = clrWhite;          // Selected border color
//+------------------------------------------------------------------+
//| Global variables
//+------------------------------------------------------------------+
int      step, arrSize;
string   arrCurrencies[], arrSymbols[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   step = 0;
   ushort separator = StringGetCharacter(",", 0);
   
   StringSplit(inpCurrencies, separator, arrCurrencies);
   StringSplit(inpSymbols,    separator, arrSymbols);
   if(ArraySize(arrCurrencies) != ArraySize(arrSymbols)) 
   {
      Alert("Quantity of currencies and symbols must be equal."); 
      return -1;
   }
   
   arrSize = ArraySize(arrCurrencies);
   for(int i = 0; i < arrSize; i++)
   {
      switch(step)
      {
         case ADD_PREFFIX:
            arrSymbols[i] = inpPreffix + arrSymbols[i];
            if(i == arrSize-1) { step++; i=-1; }
            break;
         case ADD_SUFFIX:
            arrSymbols[i] += inpSuffix;
            if(i == arrSize-1) { step++; i=-1; }
            break;
         case CREATE_BUTTONS:
            CreateButton(0, arrCurrencies[i], i);
            break;
         default: break;         
      }
   }
   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      int curIndex = -1;
      
      for(int i = 0 ; i < arrSize; i++)
      {
         ObjectSetInteger(0, sparam, OBJPROP_STATE,        false);
         ObjectSetInteger(0, sparam, OBJPROP_COLOR,        inpNormalTxtClr);
         ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR,      inpNormalBgClr);
         ObjectSetInteger(0, sparam, OBJPROP_BORDER_COLOR, inpNormalBdrClr);
         
         if(StringFind(sparam, arrCurrencies[i]) > 0) curIndex = i;
      }
      
      ChartSetSymbolPeriod(0, arrSymbols[curIndex], Period());
            
      ObjectSetInteger(0, sparam, OBJPROP_STATE,        true);
      ObjectSetInteger(0, sparam, OBJPROP_COLOR,        inpSelectedTxtClr);
      ObjectSetInteger(0, sparam, OBJPROP_BGCOLOR,      inpSelectedBgClr);
      ObjectSetInteger(0, sparam, OBJPROP_BORDER_COLOR, inpSelectedBdrClr);
   }
   //--- End Of Function
}
//+------------------------------------------------------------------+
//| OnDeinit function                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, PREFFIX_OBJNAME);
   ChartRedraw();
}
//+------------------------------------------------------------------+
//| CreateButton function                                            |
//+------------------------------------------------------------------+
bool CreateButton(const int id, const string currency, const int i)
{
   bool result = false;
   string name = PREFFIX_OBJNAME + "_BTN_" + currency;
   Print(__FUNCTION__+": obj_name = "+name);
   if(ObjectCreate(id, name, OBJ_BUTTON, 0, 0, 0))
   {
      ObjectSetInteger(id, name, OBJPROP_XDISTANCE,      inpMoveX + (inpWidth * i));
      ObjectSetInteger(id, name, OBJPROP_YDISTANCE,      inpMoveY);
      ObjectSetInteger(id, name, OBJPROP_XSIZE,          inpWidth);
      ObjectSetInteger(id, name, OBJPROP_YSIZE,          inpHeight);
      ObjectSetInteger(id, name, OBJPROP_BGCOLOR,        inpNormalBgClr);
      ObjectSetInteger(id, name, OBJPROP_COLOR,          inpNormalTxtClr);
      ObjectSetInteger(id, name, OBJPROP_BORDER_COLOR,   inpNormalBdrClr);
      ObjectSetInteger(id, name, OBJPROP_STATE,          false);
      ObjectSetString( id, name, OBJPROP_TEXT,           currency);
      result = true;
   }
   return result;
}
//+------------------------------------------------------------------+
//| End Of File (EOF)                                                |
//+------------------------------------------------------------------+
