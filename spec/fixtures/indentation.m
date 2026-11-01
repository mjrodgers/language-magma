// Indentation fixture: every row is indented the way the grammar should
// indent it (4 spaces per level).

intrinsic DoubleCosetRepresentatives(G::Grp, H::Grp, K::Grp : Verbose := false) -> SeqEnum
{Returns representatives of the double cosets H \ G / K.}
    require H subset G and K subset G: "H and K must be subgroups of G";
    reps := [];
    for g in G do
        if forall{ r : r in reps | not IsDoubleCosetEqual(H, r, g, K) } then
            Append(~reps, g);
        elif Verbose then
            vprint User1: "skipping", g;
        else
            continue;
        end if;
    end for;
    return reps;
end intrinsic;

square := function(x)
    return x^2;
end function;

procedure Bump(~n)
    n +:= 1;
end procedure;

function Fib(n)
    if n le 1 then
        return n;
    end if;
    return Fib(n - 1) + Fib(n - 2);
end function;

i := 0;
while i lt 10 do
    i +:= 1;
    case i mod 3:
        when 0:
            print "fizz";
        when 1:
            print "one";
        else
            print "other";
    end case;
end while;

repeat
    i -:= 1;
until i le 0;

try
    x := 1/0;
catch e
    print e`Object;
end try;

S := [
    1,
    2
];

G := sub< Sym(4) |
    (1,2), (1,2,3,4)
>;

R<x> := PolynomialRing(Rationals());
f := x^2 + 1;
