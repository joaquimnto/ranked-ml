WITH tb_lobby AS (
    SELECT
        *
    FROM
        tb_lobby_stats_player
    WHERE
        dtCreatedAt < '2022-02-01'
        AND dtCreatedAt > date('2022-02-01', '-30 day')
),
tb_stats AS (
    SELECT
        idPlayer,
        COUNT(DISTINCT idLobbyGame) AS qtPartidas,
        COUNT(DISTINCT CASE WHEN qtRoundsPlayed < 16 THEN idLobbyGame END) AS qtPartidasMenos16,
        COUNT(DISTINCT date(dtCreatedAt)) AS qtDias,
        1.0 * COUNT(DISTINCT idLobbyGame)/COUNT(DISTINCT date(dtCreatedAt)) AS qtMediaPartidasDia,
        AVG(qtKill) AS avgQtKill,
        AVG(qtAssist) AS avgQtAssist,
        AVG(qtDeath) AS avgQtDeath,
        AVG(1.0 * (qtKill+qtAssist)/qtDeath) AS avgKDA,
        1.0 * SUM(qtKill+qtAssist)/SUM(qtDeath) AS KDAgeral,
        AVG(1.0 * (qtKill+qtAssist)/qtRoundsPlayed) AS avgKARound,
        1.0 * SUM(qtKill+qtAssist)/SUM(qtRoundsPlayed) AS KARoundGeral,
        AVG(qtHs) AS avgQtHs,
        AVG(1.0 * qtHs/qtKill) AS avgHsRate,
        1.0 * SUM(qtHs)/qtKill AS txHsGeral,
        AVG(qtBombeDefuse) AS avgQtBombeDefuse,
        AVG(qtBombePlant) AS avgQtBombePlant,
        AVG(qtTk) AS avgQtTk,
        AVG(qtTkAssist) AS avgQtTkAssist,
        AVG(qt1Kill) AS avgQt1Kill,
        AVG(qt2Kill) AS avgQt2Kill,
        AVG(qt3Kill) AS avgQt3Kill,
        AVG(qt4Kill) AS avgQt4Kill,
        SUM(qt4Kill) AS sumQt4Kill,
        AVG(qt5Kill) AS avgQt5Kill,
        SUM(qt5Kill) AS sumQt5Kill,
        AVG(qtPlusKill) AS avgQtPlusKill,
        AVG(qtFirstKill) AS avgQtFirstKill,
        AVG(vlDamage) AS avgVlDamage,
        AVG(1.0 * vlDamage/qtRoundsPlayed) AS avgDamageRound,
        1.0 * SUM(vlDamage)/SUM(qtRoundsPlayed) AS DamageRoundGeral,
        AVG(qtHits) AS avgQtHits,
        AVG(qtShots) AS avgQtShots,
        AVG(qtLastAlive) AS avgQtLastAlive,
        AVG(qtClutchWon) AS avgQtClutchWon,
        AVG(qtRoundsPlayed) AS avgQtRoundsPlayed,
        AVG(descMapName) AS avgDescMapName,
        AVG(vlLevel) AS avgVlLevel,
        AVG(qtSurvived) AS avgQtSurvived,
        AVG(qtTrade) AS avgQtTrade,
        AVG(qtFlashAssist) AS avgQtFlashAssist,
        AVG(qtHitHeadshot) AS avgQtHitHeadshot,
        AVG(qtHitChest) AS avgQtHitChest,
        AVG(qtHitStomach) AS avgQtHitStomach,
        AVG(qtHitLeftAtm) AS avgQtHitLeftAtm,
        AVG(qtHitRightArm) AS avgQtHitRightArm,
        AVG(qtHitLeftLeg) AS avgQtHitLeftLeg,
        AVG(qtHitRightLeg) AS avgQtHitRightLeg,
        AVG(flWinner) AS avgFlWinner,
        AVG(dtCreatedAt) AS avgDtCreatedAt,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_mirage' THEN idLobbyGame END) AS qtMiragePartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_mirage' AND flWinner = 1 THEN idLobbyGame END) AS qtMirageVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_nuke' THEN idLobbyGame END) AS qtNukePartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_nuke' AND flWinner = 1 THEN idLobbyGame END) AS qtNukeVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_inferno' THEN idLobbyGame END) AS qtInfernoPartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_inferno' AND flWinner = 1 THEN idLobbyGame END) AS qtInfernoVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_vertigo' THEN idLobbyGame END) AS qtVertigoPartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_vertigo' AND flWinner = 1 THEN idLobbyGame END) AS qtVertigoVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_ancient' THEN idLobbyGame END) AS qtAncientPartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_ancient' AND flWinner = 1 THEN idLobbyGame END) AS qtAncientVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_dust2' THEN idLobbyGame END) AS qtDust2Partida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_dust2' AND flWinner = 1 THEN idLobbyGame END) AS qtDust2Vitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_train' THEN idLobbyGame END) AS qtTrainPartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_train' AND flWinner = 1 THEN idLobbyGame END) AS qtTrainVitorias,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_overpass' THEN idLobbyGame END) AS qtOverpassPartida,
        COUNT(DISTINCT CASE WHEN descMapName = 'de_overpass' AND flWinner = 1 THEN idLobbyGame END) AS qtOverpasVitorias
    FROM 
        tb_lobby
    GROUP BY 
        idPlayer
),
tb_level_atual AS (
    SELECT
        idPlayer,
        vlLevel
    FROM(
        SELECT
            idLobbyGame,
            idPlayer,
            vlLevel,
            dtCreatedAt,
            ROW_NUMBER() OVER(PARTITION BY idPlayer ORDER BY dtCreatedAt DESC) AS rn
        FROM
            tb_lobby
    )
    WHERE rn = 1
)

SELECT
    t1.*,
    t2.vlLevel as vlLevelAtual
FROM
    tb_stats AS t1
LEFT JOIN tb_level_atual AS t2
    ON t1.idPlayer = t2.idPlayer    