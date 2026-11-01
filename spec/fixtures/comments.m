// A header comment
// that runs over three lines
// before the code starts.
xLinesI := [ {z : z in Points(ell) | z in I} : ell in xLines];
    // NOTE should this be a map from xLines -> subsets of I?
    // NOTE we aren't using xLinesW or LineMapW_pts here
    // debateable whether we REALLY need xLinesI - expensive to compute


    // NOTE : now: returns a matrix in GV sending <x>_E :-> <pt>_E
    // function pt_recog(pt)
    //     if pt subset W then
    //
    //     end if;
    // end function;

    // Define IMap (name sucks) - given a point pt of V,
    // return the set of points in I that are collinear with pt
y := 2;
// a single comment
z := 3; // a trailing comment
// right after it
for i in [1..3] do
    print i;
    // two comments
    // at the end of a body
end for;
