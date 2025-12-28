SELECT
    (SELECT COUNT(*) FROM raw.trades) AS raw_count,
    (SELECT COUNT(*) FROM dw.trades) AS dw_count;

SELECT symbol, COUNT(*) AS error_count
FROM dw.trades
WHERE symbol !~ '^[A-Z0-9]+$'
GROUP BY symbol;

SELECT
    d.trade_id,
    d.version as dw_version,
    r.max_version as raw_max_valid_version
FROM dw.trades as d
JOIN (
    SELECT
        trade_id::bigint as trade_id,
        MAX(version::int) as max_version
    FROM raw.trades
    WHERE
        trade_id ~ '^\d+$'
        AND user_id ~ '^\d+$'
        AND upper(trim(side)) IN ('BUY', 'SELL')
        AND upper(trim(symbol)) != ''
        AND quantity ~ '^\d+(\.\d+)?$'
        AND price ~ '^\d+(\.\d+)?$'
        AND trade_ts IS NOT NULL
        AND trade_ts <> ''
        AND version::int >= 1
        AND version ~ '^\d+$'    
    GROUP BY trade_id::bigint    
) as r
ON d.trade_id = r.trade_id
WHERE d.version != r.max_version
ORDER BY d.trade_id