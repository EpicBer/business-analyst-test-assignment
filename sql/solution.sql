SET search_path TO pass_test, public;

-- Задание 1. Повторяющиеся документы
SELECT
    document_number,
    COUNT(person_id) AS person_count
FROM pass_test.persons
GROUP BY document_number
HAVING COUNT(person_id) > 1;

-- Задание 2. Некорректные периоды действия
SELECT
    request_id,
    requested_from,
    requested_to,
    status
FROM pass_test.pass_requests
WHERE requested_to < requested_from;


-- Задание 3. Отсутствующие обязательные согласования
SELECT
    pr.request_id,
    MAX(CASE WHEN a.approval_type = 'SECURITY' THEN a.decision END) AS security_decision,
    MAX(CASE WHEN a.approval_type = 'MANAGER' THEN a.decision END) AS manager_decision
FROM pass_test.pass_requests pr
         LEFT JOIN pass_test.approvals a ON pr.request_id = a.request_id
WHERE pr.status = 'APPROVED'
GROUP BY pr.request_id
HAVING
    COUNT(CASE
        WHEN a.approval_type = 'SECURITY'
         AND a.decision = 'APPROVED' THEN 1
    END) = 0
    OR COUNT(CASE
        WHEN a.approval_type = 'MANAGER'
         AND a.decision = 'APPROVED' THEN 1
    END) = 0;

-- Задание 4. Ошибочно разрешённый автомобильный доступ
SELECT
    p.pass_id,
    p.request_id,
    pr.vehicle_requested,
    MAX(CASE WHEN a.approval_type = 'TRANSPORT' THEN a.decision END) AS transport_decision
FROM pass_test.passes p
         JOIN pass_test.pass_requests pr ON p.request_id = pr.request_id
         LEFT JOIN pass_test.approvals a ON pr.request_id = a.request_id
WHERE p.vehicle_access_allowed = TRUE
GROUP BY p.pass_id, p.request_id, pr.vehicle_requested
HAVING
    pr.vehicle_requested = FALSE
    OR COUNT(CASE
        WHEN a.approval_type = 'TRANSPORT'
         AND a.decision = 'APPROVED' THEN 1
    END) = 0;

-- Задание 5. Несогласованные зоны
SELECT
    p.pass_number,
    p.request_id,
    z.zone_name,
    rz.decision
FROM pass_test.passes p
         JOIN pass_test.pass_zones pz ON p.pass_id = pz.pass_id
         JOIN pass_test.zones z ON pz.zone_id = z.zone_id
         LEFT JOIN pass_test.request_zones rz
                   ON p.request_id = rz.request_id AND pz.zone_id = rz.zone_id
WHERE rz.decision IS NULL
   OR rz.decision IN ('REJECTED', 'PENDING');

-- Задание 6. Ошибки активных пропусков
SELECT
    pass_id,
    pass_number,
    issued_at,
    activated_at,
    revoked_at
FROM pass_test.passes
WHERE status = 'ACTIVE'
  AND (
    issued_at IS NULL
        OR activated_at IS NULL
        OR revoked_at IS NOT NULL
        OR activated_at < issued_at
    );

-- Задание 7. Несколько активных пропусков
SELECT
    request_id,
    COUNT(pass_id) AS active_passes_count
FROM pass_test.passes
WHERE status = 'ACTIVE'
GROUP BY request_id
HAVING COUNT(pass_id) > 1;

-- Задание 8. Статистика заявок
SELECT
    pass_type,
    status,
    COUNT(request_id) AS request_count
FROM pass_test.pass_requests
GROUP BY pass_type, status
ORDER BY pass_type, status;

-- Дополнительное задание
SELECT 'approval' AS error_type, a.request_id, a.decided_at AS event_date, pr.created_at AS request_created
FROM pass_test.approvals a
         JOIN pass_test.pass_requests pr ON a.request_id = pr.request_id
WHERE a.decided_at < pr.created_at

UNION ALL

SELECT 'pass_issue', p.request_id, p.issued_at, pr.created_at
FROM pass_test.passes p
         JOIN pass_test.pass_requests pr ON p.request_id = pr.request_id
WHERE p.issued_at < pr.created_at

UNION ALL

SELECT 'event', re.request_id, re.event_at, pr.created_at
FROM pass_test.request_events re
         JOIN pass_test.pass_requests pr ON re.request_id = pr.request_id
WHERE re.event_at < pr.created_at

UNION ALL

SELECT
    'request_approval' AS error_type,
    pr.request_id,
    pr.approved_at AS event_date,
    pr.created_at AS request_created
FROM pass_test.pass_requests pr
WHERE pr.approved_at < pr.created_at;
