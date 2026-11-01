// line comment
/* block
   comment */
intrinsic Order2(G::GrpPerm : Strict := false) -> RngIntElt
{Returns the number of elements of order 2 in G.}
    return #[ g : g in G | Order(g) eq 2 ];
end intrinsic;

square := function(x)
    return x^2;
end function;

declare verbose MyFlag, 2;
n := 42;
r := 1.5;
b := true;
s := "hello\n";
for i in [1..n] do
    if IsEven(i) then
        print n;
    end if;
end for;
n +:= 1;
H := sub< Sym(3) | (1,2) >;
R<x> := PolynomialRing(Rationals());
o := G`Order;
load "other.m";
try
    error "boom";
catch e
    print e`Object;
end try;
inc := func< v, ~acc : Step := 1 | v + Step >;
RF := recformat< count : RngIntElt, label >;
rr := rec< RF | count := 3 >;
declare type MyGrp: Grp;
declare attributes Grp: Weight, Colour;
c := case< n | 1 : "one", default : "many" >;
pick := rep{ k : k in [1..5] | IsOdd(k) };
m := map< Integers() -> Integers() | t :-> t + 1 >;
lit := \[ 1, 2 ];
