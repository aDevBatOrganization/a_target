function GetCursorScreenPosition()
    return vector2(GetControlNormal(0, 239), GetControlNormal(0, 240))
end

function ScreenToWorld(screenPosition, maxDistance)
    local pos = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    local fov = GetGameplayCamFov()
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, rot.x, rot.y, rot.z, fov, 0, 2)
    local camRight, camForward, camUp, camPos = GetCamMatrix(cam)
    DestroyCam(cam, true)

    screenPosition = vector2(screenPosition.x - 0.5, screenPosition.y - 0.5) * 2.0

    local fovRadians = DegreesToRadians(fov)
    local resX, resY = GetActiveScreenResolution()
    local to = camPos + camForward + (camRight * screenPosition.x * fovRadians * (resX / resY) * 0.534375) -
        (camUp * screenPosition.y * fovRadians * 0.534375)

    local direction = (to - camPos) * maxDistance
    local endPoint = camPos + direction

    local rayHandle = StartShapeTestRay(camPos.x, camPos.y, camPos.z, endPoint.x, endPoint.y, endPoint.z, -1, nil, 0)
    local _, hit, worldPosition, normalDirection, entity = GetShapeTestResult(rayHandle)

    if (hit == 1) then
        return true, worldPosition, normalDirection, entity
    else
        return false, vector3(0, 0, 0), vector3(0, 0, 0), nil
    end
end

function DegreesToRadians(degrees)
    return (degrees * 3.14) / 180.0
end
