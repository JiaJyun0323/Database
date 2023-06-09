CREATE OR ALTER FUNCTION [dbo].[find_crossover_date]
(	
	-- Add the parameters for the function here
	@company varchar(10),
	@change_interval int
)
RETURNS @trend_tmp TABLE
(
	date date Not Null,
	company varchar(10) Not Null,
	MA_price real,
	close_price real Not null,
	/*高於均線還是低於均線 ( 0->lower_region, 1->upper_region ) */
	point_region INT,
	/*是否為交界點 (0->not crossover_point, 1->crossover_point) */
	crossover_point INT,
	/*最後決定的區間*/
	cur_trend INT,
	/*區間已經連續變化幾天*/
	counter int
)
AS
BEGIN
	/* Insert stock_info */
	INSERT @trend_tmp (date, company, MA_price, close_price)
	SELECT date, stock_code, MA5, c
	FROM dbo.stock_data
	WHERE stock_code = @company
	order by date desc
	
	/* Find point belong which region according to MA_price and Close_price */
	UPDATE @trend_tmp
	SET point_region = 0
	WHERE MA_price > close_price

	UPDATE @trend_tmp
	SET point_region = 1
	WHERE MA_price <= close_price

	/* Check point is crossover point or not (if the point region change lasts three days)*/
	DECLARE cur CURSOR LOCAL for
		SELECT date, company, point_region FROM @trend_tmp
	open cur
	DECLARE @current_trend INT
	DECLARE @DAY_change_count INT

	DECLARE @date_tmp date, @company_tmp varchar(10), @point_region_tmp INT
	FETCH next from cur into @date_tmp, @company_tmp, @point_region_tmp

	SET @current_trend = @point_region_tmp 
	SET @DAY_change_count = 0
	WHILE @@FETCH_STATUS = 0 BEGIN
		SELECT @DAY_change_count = COUNT(*)
		FROM @trend_tmp
		WHERE point_region != @current_trend AND date in (SELECT date FROM find_date(@date_tmp, @change_interval, 1, 0))
	
		IF(@DAY_change_count >= @change_interval)
			BEGIN
				UPDATE @trend_tmp
				SET crossover_point = 1
				WHERE date = @date_tmp
				IF(@current_trend = 0)
					SET @current_trend = 1
				ELSE
					SET @current_trend = 0
			END

		UPDATE @trend_tmp
		SET counter = @DAY_change_count, cur_trend = @current_trend
		WHERE date = @date_tmp

		FETCH next from cur into @date_tmp, @company_tmp, @point_region_tmp
	END
	close cur

	return
END;
