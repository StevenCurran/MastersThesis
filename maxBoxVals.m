function localBoxes = maxBoxVals(finalBoxes)

rects = [];
for es = 1 : length(finalBoxes)
    y = finalBoxes(es, 1); 
    x = finalBoxes(es, 2); 
    y2 = finalBoxes(es, 3);
    x2 = finalBoxes(es, 4); 
    rects = [rects ; [x, y, y2-y, x2 - x]];
end

overlaps = rectint(rects, rects);

%overlaps(logical(eye(size(overlaps)))) = 0;

[r,c] = find(overlaps > 0);
localBoxes = [];

for i = 1 : length(overlaps)
    col = overlaps(:,i);
    col2 = find(col > 0);
    
    if(~length(col2) > 0)
        continue;
    end
    localRects = [rects(i,:)];
    for j = 1 : length(col2)
        if(j ~= i)
            localRects = [localRects ; rects(col2(j),:)];
        end
    end
    
    if(max(localRects) > 0)
        minX = min(localRects(:,1));
        minY = min(localRects(:,2));
        maxX = max(localRects(:,1))+max(localRects(:,3));
        maxY = max(localRects(:,2))+max(localRects(:,4));
        localBoxes = [localBoxes ; [minX,minY,maxX - minX, maxY - minY]];
    end
    
end

localBoxes = unique(localBoxes,'rows')



end
