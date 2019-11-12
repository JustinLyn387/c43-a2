SET search_path TO A2;

--If you define any views for a question (you are encouraged to), you must drop them
--after you have populated the answer table for that question.
--Good Luck!

--Query 1
INSERT INTO query1
(SELECT player.pid as pname, country.cname as cname, tournament.tid as tname 
FROM country, player, tournament, champion
WHERE country.cid = player.cid and player.pid = champion.pid
and champion.tid = tournament.tid and player.cid = tournament.cid
ORDER BY pname);


--Query 2
CREATE VIEW Capacities as
(Select tid, sum(capacity) as total from court group by tid);

CREATE VIEW MaxCapacity as
(Select max(total) as totalCapacity
FROM Capacities );

INSERT INTO query2(
SELECT tname, totalCapacity
FROM tournament,Capacities, MaxCapacity 
WHERE tournament.tid = Capacities.tid and MaxCapacity.totalCapacity = Capacities.total
ORDER BY tname);

DROP VIEW MaxCapacity, Capacities;

--Query 3
CREATE VIEW Ranks As
(SELECT winid as p1, MIN(player.globalRank) as maxOponentRank
FROM player, event
WHERE player.pid = event.lossid
GROUP BY Event.winid);

CREATE VIEW P2Names AS
(SELECT player.pname as p2name, player.pid as p2, Ranks.p1 as p1, ranks.maxOponentRank
FROM player, Ranks
WHERE ranks.maxOponentRank = player.globalRank);

CREATE VIEW Opponents AS
(SELECT P2Names.p1 as p1, P2Names.p2 as p2, P2Names.p2name as p2name
FROM event, P2Names 
WHERE event.winid = P2Names.p1 and event.lossid = P2Names.p2);

INSERT INTO query3(
SELECT player.pid as p1id,  player.pname as p1name, P2Names.p2 as p2id, P2Names.p2name as p2name
FROM player, Opponents, P2Names
WHERE player.pid = Opponents.p1 AND p2names.p2 =  Opponents.p2
ORDER BY p1name);

DROP VIEW Opponents, P2Names, Ranks;

--Query 4
INSERT INTO query4(
SELECT player.pid, pname
FROM champion, player
WHERE champion.pid = player.pid 
GROUP BY player.pid 
HAVING count(DISTINCT tid)=(SELECT  count(*) FROM tournament)
ORDER BY pname);

--Query 5
CREATE VIEW averages as
(SELECT pid, Sum(wins)/4.0 as avg
FROM record
WHERE record.year>= 2011 and record.year<=2014
GROUP BY pid);

INSERT INTO query5(
SELECT averages.pid as pid, player.pname as pname, averages.avg as avgwins
FROM player, averages
WHERE player.pid = averages.pid
ORDER BY avgwins DESC);

DROP VIEW averages;

--Query 6
CREATE VIEW view2011Wins AS
(SELECT pid, wins
FROM record
WHERE record.year= 2011);


CREATE VIEW view2012Wins AS
(SELECT pid, wins
FROM record
WHERE record.year= 2012);


CREATE VIEW view2013Wins AS
(SELECT pid, wins
FROM record
WHERE record.year= 2013);


CREATE VIEW view2014Wins AS
(SELECT pid, wins
FROM record
WHERE record.year= 2014);

CREATE VIEW increasing AS
(SELECT view2012wins.pid
FROM view2011Wins , view2012Wins , view2013Wins , view2014Wins 
WHERE view2011wins.wins < view2012wins.wins and view2012wins.wins < view2013wins.wins and view2013wins.wins < view2014wins.wins and view2011wins.pid = view2012wins.pid and view2012wins.pid = view2013wins.pid and view2013wins.pid = view2014wins.pid);

INSERT INTO query6(
SELECT player.pid as pid, player.pname as pname
FROM player, increasing
WHERE player.pid = increasing.pid
ORDER BY pname);

DROP VIEW increasing, view2014wins, view2013wins, view2012wins, view2011wins;

--Query 7
CREATE VIEW AtleastTwice AS
(SELECT pid, year
FROM champion
GROUP BY pid, year
HAVING Count(tid)>=2);

INSERT INTO query7 (pname, year)
SELECT player.pname as pname, AtleastTwice.year as year
FROM player, AtleastTwice
WHERE player.pid = AtleastTwice.pid
ORDER BY pname DESC, year DESC;

DROP VIEW AtleastTwice;

--Query 8
CREATE VIEW player1 AS
(SELECT pname as p1name, cid, player.pid as p1id
FROM player, event 
WHERE player.pid = event.winid);

CREATE VIEW player2 AS
(SELECT pname as p2name, cid, player.pid as p2id
FROM player, event 
WHERE player.pid = event.lossid);

CREATE VIEW bothPlayers AS
(SELECT p1name, p2name, player1.cid
FROM player1, player2, event
WHERE player1.cid = player2.cid and event.winid = player1.p1id and event.lossid = player2.p2id);

CREATE VIEW bothPlayersReverse AS
(SELECT p2name as p1name, p1name as p2name, player1.cid
FROM player1, player2, event
WHERE player1.cid = player2.cid and event.winid = player1.p1id and event.lossid = player2.p2id);

INSERT INTO query8 (p1name, p2name, cname) (SELECT DISTINCT p1name, p2name, cname
FROM ((SELECT * FROM bothPlayers) UNION ALL (SELECT * FROM bothPlayersReverse)) players, country 
WHERE players.cid = country.cid
ORDER BY cname ASC, p1name DESC);

DROP VIEW bothPlayersReverse, bothPlayers, player2, player1;

--Query 9
CREATE VIEW CountryPlayers AS
(SELECT country.cid as cid, Count(champion.tid) as championships
FROM player, country, champion
WHERE player.cid = country.cid and player.pid  = champion.pid
GROUP BY country.cid, champion.pid);

INSERT INTO query9(
SELECT country.cname as cname, SUM(CountryPlayers.championships) as champions
FROM country, CountryPlayers 
WHERE country.cid = CountryPlayers.cid and CountryPlayers.championships = (SELECT MAX(championships) from CountryPlayers)
GROUP BY country.cname
ORDER BY cname);

DROP VIEW CountryPlayers;

--Query 10
CREATE VIEW winners AS
(SELECT event.courtid as courtid, event.winid as winid, Count(*) as wins
FROM event
WHERE event.year =2014
GROUP BY event.courtid, event.winid);

CREATE VIEW losers AS
(SELECT event.courtid as courtid, event.lossid as lossid, Count(*) as loss
FROM event
WHERE event.year =2014
GROUP BY event.courtid, event.lossid);

CREATE VIEW MoreWins AS
(SELECT DISTINCT winners.winid as pid
FROM winners, losers
WHERE  ((winners.winid = losers.lossid AND winners.wins >losers.loss) OR NOT EXISTS(SELECT * FROM losers WHERE losers.lossid = winners.winid )));

CREATE VIEW WinDuration AS
(SELECT winid as pid, duration
FROM event);

CREATE VIEW LossDuration AS
(SELECT lossid as pid, duration
FROM event);

CREATE VIEW AverageDuration AS
(SELECT pid, avg(duration) as duration
	FROM ((SELECT * FROM WinDuration) UNION ALL (SELECT * FROM LossDuration)) average
	GROUP BY pid);

CREATE VIEW Players AS
	(SELECT MoreWins.pid
	FROM AverageDuration, MoreWins
	WHERE MoreWins.pid = AverageDuration.pid and AverageDuration.duration > 200);

INSERT INTO query10(
SELECT player.pname as pname
FROM Players, player
WHERE Players.pid = player.pid
ORDER BY pname DESC);

DROP VIEW Players, AverageDuration, LossDuration, WinDuration, MoreWins, losers, winners;

