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
       function this = DiscriminateClassifier(A, B, maxClassifiers)

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
                    
                    if(nargin >= 3 && size(this.G) >= maxClassifiers)
                       %check if we have reached the maximum number of classifiers
                       break;
                    end
                    
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
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
       function class = Classify(this, x)
           %x is a two column, m x 2 element matrix containing the points to classify 
           %class is a m x 1 vector where each element is either 1 or 2
           
           class = zeros(size(x,1),1);
           
           for j = 1:size(this.G, 1)
               
               classifierClass = mod((~this.G(j, 5:6))*[2;1], 3);
               x_Classified = classify_MED(x, [this.G(j,1:2);this.G(j,3:4)]);
               
               if (classifierClass == 0 || j == size(this.G, 1))
                    %error('temp');
                    class = class + (~class).*(x_Classified*[1;2]);
               else
                    class = class + (~class).*(classifierClass*x_Classified(:,classifierClass));
               end
               
               if (min(min(class)) > 0)
                  return; %everything has been fully classified
               end
           end
           
           class = class + ~class; %set any undecided elements as class A
       end %Classify
       
       function boundaryContour = GenerateContourMatrix(this, x1Range, x2Range)
           
           x1Start = min(min(x1Range));
           x1End = max(max(x1Range));
           
           x2Start = min(min(x2Range));
           x2End = max(max(x2Range));

           boundaryContour = zeros(x2End - x2Start + 1, x1End - x1Start + 1);
           
           x2Input = (x2Start:x2End)';
           x1InputTemplate = ones(x2End-x2Start + 1, 1); 
 
           for x1 = x1Start:x1End

               toClassify = [x1InputTemplate*x1, x2Input];
               
               boundaryContour(:,x1 - x1Start + 1) = this.Classify(toClassify);
           end
       end %Generate contour
       
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