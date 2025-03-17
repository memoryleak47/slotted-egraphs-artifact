use crate::*;

#[derive(PartialEq, Eq, Clone, Debug)]
pub struct SdqlKind {
    pub mightBeVector: bool,
    pub mightBeDict: bool,
    pub mightBeScalar: bool,
    pub mightBeBool: bool,
}

impl Analysis<Sdql> for SdqlKind {
    fn make(eg: &slotted_egraphs::EGraph<Sdql, Self>, enode: &Sdql) -> Self {
        let mut out = SdqlKind {
            mightBeVector: false,
            mightBeDict: false,
            mightBeScalar: false,
            mightBeBool: false,
        };
        match enode {
            Sdql::SubArray(..) | Sdql::Range(..) => {
                out.mightBeVector = true;
            }
            Sdql::Equality(..) => {
                out.mightBeBool = true;
            }
            Sdql::Num(..) => {
                out.mightBeScalar = true;
            }
            Sdql::Sing(..) => {
                out.mightBeDict = true;
            }
            // Sdql::Sum(_, _, _, body) => {
            //     out = eg.analysis_data(body.id).clone();
            // }
            _ => {},
        }
        out
    }

    fn merge(a: Self, b: Self) -> Self {
        SdqlKind {
            mightBeVector: a.mightBeVector || b.mightBeVector,
            mightBeDict: a.mightBeDict || b.mightBeDict,
            mightBeScalar: a.mightBeScalar || b.mightBeScalar,
            mightBeBool: a.mightBeBool || b.mightBeBool,
        }
    }
}
