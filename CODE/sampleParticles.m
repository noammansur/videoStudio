function S_next_tag = sampleParticles(S_prev, C)

[a, N] = size(S_prev);

S_next_tag = zeros(a, N);

for i=1:N
    r = rand();
    index = N;
    for j=1:N
        if (C(j)>=r)
            index = j;
            break
        end
    end

    S_next_tag(:,i) = S_prev(:,index);
end
   
end 
