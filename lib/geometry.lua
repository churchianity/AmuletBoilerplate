
function circles_intersect(center1, center2, radius1, radius2)
    local c1, c2, r1, r2 = center1, center2, radius1, radius2
    local d = math.distance(center1, center2)
    local radii_sum = r1 + r2
                                    -- touching
    if d == radii_sum then          return 1

                                    -- not touching or intersecting
    elseif d > radii_sum then       return false

                                    -- intersecting
    else                            return 2
    end
end

function point_in_rect(point, rect)
    return point.x > rect.x1
       and point.x < rect.x2
       and point.y > rect.y1
       and point.y < rect.y2
end

function rect_in_rect(r1, r2)
    if r1.x2 >= r2.x1       -- r1 right edge past r2 left
        and r1.x1 <= r2.x2  -- r1 left edge past r2 right
        and r1.y2 >= r2.y1  -- r1 top edge past r2 bottom
        and r1.y1 <= r2.y2  -- r1 bottom edge past r2 top
    then
        return true
    else
        return false
    end
end

