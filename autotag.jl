
@assert length(ARGS) == 1 "Need one argument of the tag"
full_tag = only(ARGS)
m = match(r"(.*):(.*)-v[^-]*", full_tag)

@assert m !== nothing

part_tag = m[1] * ":" * m[2]
min_tag = m[1] * ":latest"

@info "Creating tags" part_tag min_tag

run(`docker tag $full_tag $part_tag`)
run(`docker tag $full_tag $min_tag`)
run(`docker push $full_tag`)
run(`docker push $part_tag`)
run(`docker push $min_tag`)
