classdef DiscriminateClassifier
%DISCRIMINATECLASSIFIER Summary of this class goes here
%   Detailed explanation goes here

   properties
       
       %Datasets
       %A;
       %B;
       
       %Format (column wise): 
       %1,2: prototype for class A
       %3,4: prototype for class B
       %5: n_aB - # of times a point from A is classified as B
       %6: n_bA - # of times a point from B is classified as A
       G; 
       
   end

   methods
       function this = DiscriminateClassifier(A, B)
           
           %TODO: consider end condition when either a or b is zero but the other is not
           
           interationCountSinceLastSave= 0;
           za_IndexPermutations = [];
           zb_IndexPermutations = [];
           
           while (size(A, 1) > 0 && size(B, 1) > 0) %iterate until all points removed
               
                %Check to make sure we have not stalled for some reason
                interationCountSinceLastSave = interationCountSinceLastSave + 1;
                if(interationCountSinceLastSave > 500)
                    G_ = this.G
                    A
                    B
                    error('Getting nowhere')
                end;
                
                %Get the indexing - so we get to every point
                if(numel(za_IndexPermutations) == 0)
                    za_IndexPermutations = randperm(size(A, 1));
                end
                if(numel(zb_IndexPermutations) == 0)
                    zb_IndexPermutations = randperm(size(B, 1));
                end
                
                za_Index = za_IndexPermutations(1);
                zb_Index = zb_IndexPermutations(1);
                
                za_IndexPermutations(1) = [];
                zb_IndexPermutations(1) = [];
                
                %za_Index = max(round(rand()*size(A,1)), 1);
                %zb_Index = max(round(rand()*size(B,1)), 1);

                za = A(za_Index, :);
                zb = B(zb_Index, :);
                z = [za; zb];
                             
                A_classified = classify_MED(A, z);
                n_aB = sum(A_classified,1);
                n_aB = n_aB(2);
               
                B_classified = classify_MED(B, z);
                n_bA = sum(B_classified,1);
                n_bA = n_bA(1);

                %see if it is any good
                if (n_aB == 0 || n_bA == 0)
                    
                    %Save the classifier
                    this.G = [this.G; za, zb, n_aB, n_bA];
                    interationCountSinceLastSave = 0;
                    
                    %Keep points which were classified incorrectly
                    if(n_aB == 0)
                        initialSize = size(B, 1);
                        
                        mask = B_classified(:, 1);
                        B = RemoveElements(B, mask);
                        
                        zb_IndexPermutations = []; %invalidate
                        endSize = size(B, 1);
                    else %n_bA == 0
                        initialSize = size(A, 1);
                        
                        mask = A_classified(:, 2);
                        A = RemoveElements(A, mask);
                        
                        za_IndexPermutations = []; %invalidate
                        endSize = size(A, 1);
                    end
                    
                    %Did not remove any elements
                    if(initialSize == endSize)
                       
                       initialSize 
                       endSize
                       warning('Did not shrink'); 
                       %mask
                       break;
                    end

                    %if(mod(size(this.G, 1), 5) == 0)
                    %   sprintf('Row Count - G:%d\tA:%d\tB:%d',size(this.G, 1),size(A, 1), size(B,1))
                    %end
                    
                end

            end
               %[classify_MED(A, z), classify_MED(B, z)]
               
           %end
           
       end %constructor
       
   end
end 


function cleared = RemoveElements(toRemove, mask)
    
    cleared = toRemove;

    if(size(mask, 2) > 1)
        error('Mask size error')
    end

    for i = 0:(size(toRemove, 1) - 1)
        i = size(toRemove, 1) - i;
        if(mask(i, 1) == 0)
            cleared(i, :) = [];
        end
    end
end