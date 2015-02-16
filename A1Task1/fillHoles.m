function bwSpudsReturn = fillHoles( bwSpuds )

    bwSpudsHoles = ~bwSpuds;    
    CCs = bwconncomp(bwSpudsHoles);
    
    % SET ALL BUT FIRST (BACKGROUND) COMPONENT TO BLACK, FILLING HOLES
    for i = 2 : CCs.NumObjects
        bwSpudsHoles(CCs.PixelIdxList{i}) = 0;
    end
    
    bwSpudsReturn = ~bwSpudsHoles;
    
end

