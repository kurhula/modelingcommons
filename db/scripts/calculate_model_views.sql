BEGIN;

INSERT INTO Model_Views
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'one_model'
      AND is_searchbot = 'false'
      AND logged_at > (SELECT max(logged_at) FROM Model_Views)
;

INSERT INTO Model_Downloads
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'download_model'
      AND is_searchbot = 'false'
      AND logged_at > (SELECT max(logged_at) FROM Model_Views)
;

INSERT INTO Model_Runs
  (logged_at, ip_address, node_id, person_id)
SELECT logged_at, ip_address, node_id, person_id
     FROM Logged_Actions
    WHERE controller = 'browse'
      AND action = 'model_contents'
      AND node_id IS NOT NULL
      AND is_searchbot = 'false'
      AND logged_at > (SELECT max(logged_at) FROM Model_Runs)
;

TRUNCATE Model_View_Counts;

INSERT INTO Model_View_Counts (count, node_id)  
      SELECT COUNT(DISTINCT ip_address) as count, node_id
	FROM Model_Views
    GROUP BY node_id;

COMMIT;

