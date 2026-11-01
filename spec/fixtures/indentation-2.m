// Two-space style, multi-line docstrings, nested definitions.
intrinsic OrbitRepresentatives(G::GrpPerm, X::SetEnum) -> SeqEnum
{Returns one element from each orbit of G on X.
 The orbits are computed naively.}
  reps := [];
  seen := {};
  for x in X do
    if x in seen then continue; end if;
    // a comment inside a loop
    orb := x^G;
    seen join:= orb;
    Append(~reps, x);
  end for;
  helper := function(y)
    if y eq 0 then
      return 1;
    else
      return y * helper(y - 1);
    end if;
  end function;
  return reps;
end intrinsic;

intrinsic Classify(L::SeqEnum : Al := "Default") -> SeqEnum
{Classify.}
  result := [ x : x in L |
    IsSquare(x) ];
  T := AssociativeArray();
  while #L gt 0 do
    x := L[1];
    Remove(~L, 1);
  end while;
  return result;
end intrinsic;
