function S_next = predictParticles(S_next_tag)

S_next_tag(1, :) = S_next_tag(1, :) + S_next_tag(5, :);
S_next_tag(2, :) = S_next_tag(2, :) + S_next_tag(6, :);

S_next = S_next_tag + randn(size(S_next_tag));

end
