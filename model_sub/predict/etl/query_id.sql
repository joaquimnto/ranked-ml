WITH tb_max_date AS (
    SELECT
        MAX(dtRef) AS date_score
    FROM
        tb_book_players
    WHERE
        idPlayer = {id_player}
)

SELECT
    *
FROM
    tb_book_players
WHERE
    idPlayer = {id_player} 
    AND dtRef = (SELECT date_score FROM tb_max_date)
