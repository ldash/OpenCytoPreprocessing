SELECT
 gsid               AS Id,
 gsname             AS Name,
 objlink            AS Path,
 gsdescription      AS Description,
 container.EntityId AS EntityId,
 created            AS Created
FROM
 gstbl
