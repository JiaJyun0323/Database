CREATE OR ALTER   FUNCTION [dbo].[GB_rule3_7]
(
	@company varchar(10),
	@bias_threshold float, --回測乖離門檻值，要低於多少才算靠近均線
	@backward_day int,
	@backward_threshold float, --往回看收盤價差門檻值
	@forward_day int,
	@forward_threshold float --往後看收盤價差門檻值
)
RETURNS @rule_3 TABLE
(
	date date, --買入的時間
	buy_or_sell int  --設buy為1、sell為-1  
)
AS
BEGIN
	/* 宣告暫存表 */
	DECLARE @temp_table TABLE
	(
		date date,
		today_c real,　
		today_MA real, 
		bias real,  --每日乖離
		trend int      --判斷現在為空頭、多頭趨勢
	)

	/* 將MA_trend資訊放入暫存表 */
	INSERT INTO @temp_table (date,today_c,today_MA,trend)
	SELECT date,today_c,MA_price,trend
	FROM find_MA_updown(@company,8,6)

	/*更新bias值至@temp_table*/



	/* 宣告cursor*/
	DECLARE cur CURSOR LOCAL for
		SELECT date,today_c,today_MA,bias,trend FROM @temp_table order by date asc
	open cur

	/* 宣告參數 */
	DECLARE @date DATE
	DECLARE @today_c REAL
	DECLARE @today_MA REAL
	DECLARE @today_bias REAL
	DECLARE @trend INT
	

	FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend

	/* 開啟cursor，隔行check trend的變化*/
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		DECLARE @return_date date = NULL

		/*  若目前為多頭趨勢，today_bias為正且小於閾值，表示K線回測均線，
            再往回看backward_day天是否股價價差%數高於backward_threshold，有則表示下跌情形，
            符合上述條件，就往後看forward_day天，須符合bias均為正，且有某天股價價差大於forward_threshold*/

		/* 趨勢為正且過度靠近均線 */
		IF(@trend = 1 AND @today_bias > 0 AND @today_bias < @bias_threshold)
			BEGIN
				/* 看前backward_day天的收盤價差否有高過@backward_threshold，以確認該天為下跌至均線附近 */

				
				/* 看後forward_day是否有回升，收盤價差大於forward_threshold，且都沒有低過均線 */
				
				
				/*確認該日期是否已經存在於表中*/
				
				
			END
			
		/* 趨勢為負且過度靠近均線 */
		ELSE IF(@trend = -1 AND @today_bias < 0 AND abs(@today_bias) < @bias_threshold)
				BEGIN
				/* 看前backward_day天收盤價差的絕對值否有高過@backward_threshold，以確認該天為上漲至均線附近 */
			
			
				/* 看後forward_day天是否有回降，收盤價差的絕對值大於forward_threshold，且都沒有高過均線 */
				
				
				/* 確認該日期是否已經存在於表中 */

				
				END

		FETCH next from cur into @date,@today_c,@today_MA,@today_bias,@trend
	END
	close cur
	DEALLOCATE cur 
	return

END