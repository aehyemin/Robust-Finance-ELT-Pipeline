BEGIN;


-- 1. user_daily 유저별 일일 거래 내역
INSERT INTO mart.user_daily (user_id, stat_date, trade_count, total_trade_amount, updated_at)
SELECT  
    user_id,
    stat_date,
    COUNT(*) AS trade_count,
    SUM(trade_amount) AS total_trade_amount,
    NOW() AS updated_at

FROM mart.fact_trades
GROUP BY user_id, stat_date
ON CONFLICT (user_id, stat_date)
DO UPDATE SET
    trade_count = EXCLUDED.trade_count,
    total_trade_amount = EXCLUDED.total_trade_amount,
    updated_at = NOW();



-- 2. symbol_daily 종목별 일일 거래

INSERT INTO mart.symbol_daily (symbol, stat_date, trade_count, total_trade_amount, volume, updated_at)
SELECT  
    symbol,
    stat_date,
    COUNT(*)::bigint AS trade_count,
    SUM(trade_amount) AS total_trade_amount,
    SUM(quantity) AS volume,
    NOW() AS updated_at

FROM mart.fact_trades
GROUP BY symbol, stat_date
ON CONFLICT (symbol, stat_date)
DO UPDATE SET
    trade_count = EXCLUDED.trade_count,
    total_trade_amount = EXCLUDED.total_trade_amount,
    volume = EXCLUDED.volume,
    updated_at = NOW();


-- 3. user_total 유저 누적 체결 금액
INSERT INTO mart.user_total (user_id, total_trade_count, total_trade_amount, to_date, updated_at)
SELECT
    user_id,
    COUNT(*)::bigint AS total_trade_count,
    SUM(trade_amount) AS total_trade_amount,
    MAX(stat_date) AS to_date,
    NOW() AS updated_at

FROM mart.fact_trades
GROUP BY user_id
ON CONFLICT (user_id)
DO UPDATE SET
    total_trade_count = EXCLUDED.total_trade_count,
    total_trade_amount = EXCLUDED.total_trade_amount,
    to_date = EXCLUDED.to_date,
    updated_at = NOW();

COMMIT;