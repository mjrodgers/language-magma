// A header comment
// that runs over three lines
// before the code starts.
xLinesI := [ {z : z in Points(ell) | z in I} : ell in xLines];
// NOTE should this be a map from xLines -> subsets of I?
// NOTE we aren't using xLinesW or LineMapW_pts here
// xLinesW := {@ V`to_W(ell) : ell in xLines @};
// debateable whether we REALLY need xLinesI - expensive to compute
y := 2;
// a single comment
z := 3;
for i in [1..3] do
    print i;
    // two comments
    // at the end of a body
end for;
