WITH tb_lobby AS (
    SELECT
        *
    FROM
        tb_lobby_stats_player
    WHERE
        dtCreatedAt < '{date}'
        AND dtCreatedAt > date('{date}', '-30 day')
),
tb_stats AS (
    SELECT
        idPlayer,
        COUNT(DISTINCT idLobbyGame) AS qtPartidas,
        COUNT(DISTINCT CASE WHEN qtRoundsPlayed < 16 THEN idLobbyGame END) AS qtPartidasMenos16,
        COUNT(DISTINCT date(dtCreatedAt)) AS qtDias,
        MIN(JULIANDAY('{date}') - JULIANDAY(dtCreatedAt)) AS qtDiasUltimaLobby,
        1.0 * COUNT(DISTINCT idLobbyGame)/COUNT(DISTINCT date(dtCreatedAt)) AS qtMediaPartidasDia,
        AVG(qtKill) AS avgQtKill,
        AVG(qtAssist) AS avgQtAssist,
        AVG(qtDeath) AS avgQtDeath,
        AVG(1.0 * (qtKill+qtAssist)/COALESCE(qtDeath, 1)) AS avgKDA,
        COALESCE(1.0 * SUM(qtKill+qtAssist)/SUM(COALESCE(qtDeath, 1)), 0) AS KDAgeral,
        AVG(1.0 * (qtKill+qtAssist)/qtRoundsPlayed) AS avgKARound,
        1.0 * SUM(qtKill+qtAssist)/SUM(qtRoundsPlayed) AS KARoundGeral,
        AVG(qtHs) AS avgQtHs,
        COALESCE(AVG(1.0 * qtHs/qtKill), 0) AS avgHsRate,
        COALESCE(1.0 * SUM(qtHs)/qtKill, 0) AS txHsGeral,
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
        COALESCE(AVG(qtSurvived), 0) AS avgQtSurvived,
        AVG(qtTrade) AS avgQtTrade,
        COALESCE(AVG(qtFlashAssist), 0) AS avgQtFlashAssist,
        COALESCE(AVG(qtHitHeadshot), 0) AS avgQtHitHeadshot,
        COALESCE(AVG(qtHitChest), 0) AS avgQtHitChest,
        COALESCE(AVG(qtHitStomach), 0) AS avgQtHitStomach,
        COALESCE(AVG(qtHitLeftAtm), 0) AS avgQtHitLeftAtm,
        COALESCE(AVG(qtHitRightArm), 0) AS avgQtHitRightArm,
        COALESCE(AVG(qtHitLeftLeg), 0) AS avgQtHitLeftLeg,
        COALESCE(AVG(qtHitRightLeg), 0) AS avgQtHitRightLeg,
        COALESCE(AVG(flWinner), 0)avgFlWinner,
        COALESCE(AVG(dtCreatedAt), 0) AS avgDtCreatedAt,
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
),
tb_book_lobby AS (
    SELECT
        t1.*,
        t2.vlLevel as vlLevelAtual
    FROM
        tb_stats AS t1
    LEFT JOIN tb_level_atual AS t2
        ON t1.idPlayer = t2.idPlayer
),
tb_medals AS (
    SELECT
        *
    FROM
        tb_players_medalha AS t1
    LEFT JOIN tb_medalha AS t2
        ON t1.idMedal = t2.idMedal
    WHERE 
        dtCreatedAt < dtExpiration
        AND dtCreatedAt < '{date}'
        AND COALESCE(dtRemove, dtExpiration) > date('{date}', '-30 day')
),
tb_book_medal AS (
    SELECT 
        idPlayer,
        COUNT(DISTINCT idMedal) AS qtMedalhaDist,
        COUNT(DISTINCT CASE WHEN dtCreatedAt > date('{date}', '-30 day') THEN id END) AS qtMedalhaAdquirida,
        SUM(CASE WHEN descMedal = 'Membro Premium' THEN 1 ELSE 0 END) AS qtPremium,
        SUM(CASE WHEN descMedal = 'Membro Plus' THEN 1 ELSE 0 END) AS qtPlus,
        MAX(CASE 
                WHEN 
                    descMedal IN('Membro Premium', 'Membro Plus')
                    AND COALESCE(dtRemove, dtExpiration) >= '{date}'
                THEN 1 ELSE 0
            END 
            ) AS AssinaturaAtiva
    FROM 
        tb_medals
    GROUP BY
        idPlayer
)
SELECT
    t1.idPlayer,
    t1.qtPartidas,
    t1.qtPartidasMenos16,
    t1.qtDias,
    t1.qtDiasUltimaLobby,
    t1.qtMediaPartidasDia,
    t1.avgQtKill,
    t1.avgQtAssist,
    t1.avgQtDeath,
    t1.avgKDA,
    t1.KDAgeral,
    t1.avgKARound,
    t1.KARoundGeral,
    t1.avgQtHs,
    t1.avgHsRate,
    t1.txHsGeral,
    t1.avgQtBombeDefuse,
    t1.avgQtBombePlant,
    t1.avgQtTk,
    t1.avgQtTkAssist,
    t1.avgQt1Kill,
    t1.avgQt2Kill,
    t1.avgQt3Kill,
    t1.avgQt4Kill,
    t1.sumQt4Kill,
    t1.avgQt5Kill,
    t1.sumQt5Kill,
    t1.avgQtPlusKill,
    t1.avgQtFirstKill,
    t1.avgVlDamage,
    t1.avgDamageRound,
    t1.DamageRoundGeral,
    t1.avgQtHits,
    t1.avgQtShots,
    t1.avgQtLastAlive,
    t1.avgQtClutchWon,
    t1.avgQtRoundsPlayed,
    t1.avgDescMapName,
    t1.avgVlLevel,
    t1.avgQtSurvived,
    COALESCE(t1.avgQtTrade, 0),
    t1.avgQtFlashAssist,
    t1.avgQtHitHeadshot,
    t1.avgQtHitChest,
    t1.avgQtHitStomach,
    t1.avgQtHitLeftAtm,
    t1.avgQtHitRightArm,
    t1.avgQtHitLeftLeg,
    t1.avgQtHitRightLeg,
    t1.avgFlWinner,
    t1.avgDtCreatedAt,
    t1.qtMiragePartida / t1.qtMirageVitorias AS winRateMirage,
    t1.qtMirageVitorias / t1.qtPartidas AS propMirageVitorias,
    t1.qtNukePartida / t1.qtNukeVitorias AS winRateNuke,
    t1.qtNukeVitorias / t1.qtPartidas AS propNukeVitorias,
    t1.qtInfernoPartida / t1.qtInfernoVitorias AS winRateInferno,
    t1.qtInfernoVitorias / t1.qtPartidas AS propInfernoVitorias,
    t1.qtVertigoPartida / t1.qtVertigoVitorias AS winRateVertigo,
    t1.qtVertigoVitorias / t1.qtPartidas AS propVertigoVitorias,
    t1.qtAncientPartida / t1.qtAncientVitorias AS winRateAncient,
    t1.qtAncientVitorias / t1.qtPartidas AS propAncientVitorias,
    t1.qtDust2Partida / t1.qtDust2Vitorias AS winRateDust2,
    t1.qtDust2Vitorias / t1.qtPartidas AS propDust2Vitorias,
    t1.qtTrainPartida / t1.qtTrainVitorias AS winRateTrain,
    t1.qtTrainVitorias / t1.qtPartidas AS propTrainVitorias,
    t1.qtOverpassPartida / t1.qtOverpasVitorias AS winRateOverpass,
    t1.qtOverpasVitorias / t1.qtPartidas AS propOverpasVitorias,
    t1.vlLevelAtual,
    COALESCE(t2.qtMedalhaDist, 0) AS qtMedalhaDist,
    COALESCE(t2.qtMedalhaAdquirida, 0) AS qtMedalhaAdquirida,
    COALESCE(t2.qtPremium, 0) AS qtPremium,
    COALESCE(t2.qtPlus, 0) AS qtPlus,
    COALESCE(t2.AssinaturaAtiva, 0) AS AssinaturaAtiva,
    t3.flFacebook,
    t3.flTwitter,
    t3.flTwitch,
    t3.descCountry,
    t3.dtBirth,
    ((JulianDay('{date}')) - JulianDay(t3.dtBirth))/365.25 AS vlIdade,
    t3.dtRegistration,
    (JulianDay('{date}')) - JulianDay(t3.dtRegistration) AS vlDiasCadastro
FROM 
    tb_book_lobby AS t1
LEFT JOIN tb_book_medal AS t2
    ON t1.idPlayer = t2.idPlayer
LEFT JOIN tb_players AS t3
    ON t1.idPlayer = t3.idPlayer