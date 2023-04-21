CREATE OR ALTER FUNCTION [dbo].[find_MA_updown]
(
	@company varchar(10),
	@interval int , --往前抓的天數
	@change_interval int --決定上升或下降的天數，若沒有則視為平緩趨勢
)
RETURNS @MA_updown_trend TABLE
(
	company varchar(10),
	date date,
	yesterday_c real,
	today_c	 real,
	yesterday_MA real,
	today_MA real, 
	MA_diff INT, /* 判斷今日與昨日的MA為正或負 */
	trend INT, 	/* 1為上漲、-1為下跌、0為盤整 */
	counter_plus int,  /* 數前幾天共有多少今日MA>昨日MA */
	counter_minus int  /* 數前幾天共有多少今日MA<昨日MA */
)
AS
BEGIN
	/* 將公司、日期、MA20、昨日的MA20放入回傳的表中*/
	/* your code here */
	
	
	/*更新MA_diff，若今天MA>昨日MA，則為1，反之則為-1*/
	UPDATE @MA_updown_trend
	SET MA_diff = 
	CASE
		WHEN date ='2022-01-03' THEN 0
		WHEN today_MA > yesterday_MA THEN 1
		WHEN today_MA < yesterday_MA THEN -1
		ELSE 0
	END

	DECLARE cur CURSOR LOCAL for
		SELECT date FROM @MA_updown_trend order by date asc
	open cur

	DECLARE @diff_plus INT
	DECLARE @diff_minus INT
	DECLARE @date_tmp date


	FETCH next from cur into @date_tmp

	WHILE @@FETCH_STATUS = 0 BEGIN
		/* your code here */
		/* 計算前面幾天有多少今日MA>昨日MA */

		
		
		/* 計算前面幾天有多少今日MA<昨日MA */

		
		
		/* 判斷上漲、下跌、平緩趨勢 */

		
		
		/* 更新 @MA_updown_trend */



		FETCH next from cur into @date_tmp
	END
	CLOSE cur
	DEALLOCATE cur 
	return
END
