BeginPackage["Chess`"]

ChessState::usage = "Converst a chess state association to a ChessState object.";
ChessPlot::usage = "Plots a ChessState.";
KnightMove::usage = "Given a list of ChessState's, returns a list of all possible actions/moves.";
ChessEvolve::usage = "Generates a new ChessState object in accordance with inputed move (e.g. {"a7" -> "\[EmptySquare]", "a6" -> "\[BlackPawn]"})";


Begin["`Private`"]

(* Chess Pieces *)

(* Chess Names *)
If[
	NotebookDirectory[] != ""
	, 
	packageDir = NotebookDirectory[];
	,
	packageDir = $InputFileName;
]
Print[packageDir];




pieceNamesShort = {"King", "Queen", "Rook", "Bishop", "Knight", "Pawn"};
wpn = Table["White" <> pieceName, {pieceName, pieceNamesShort}];
bpn = Table["Black" <> pieceName, {pieceName, pieceNamesShort}];
pieceNames = wpn ~Join~ bpn;
AppendTo[pieceNames, "EmptySquare"];


whitePieces = {"\[WhiteKing]", "\[WhiteQueen]", "\[WhiteRook]", "\[WhiteBishop]", "\[WhiteKnight]", "\[WhitePawn]"};
blackPieces = {"\[BlackKing]", "\[BlackQueen]", "\[BlackRook]", "\[BlackBishop]", "\[BlackKnight]", "\[BlackPawn]"} ;
pieceSymbols = whitePieces ~Join~ blackPieces ~Join~ {"\[EmptySquare]"};
{\[WhiteKing], \[WhiteQueen], \[WhiteRook], \[WhiteBishop], \[WhiteKnight], \[WhitePawn], \[BlackKing], \[BlackQueen], \[BlackRook], \[BlackBishop], \[BlackKnight], \[BlackPawn], \[EmptySquare]} = pieceSymbols;
(*{\[WhiteKing], \[WhiteQueen], \[WhiteRook], \[WhiteBishop], \[WhiteKnight], \[WhitePawn], \[BlackKing], \[BlackQueen], \[BlackRook], \[BlackBishop], \[BlackKnight], \[BlackPawn], \[EmptySquare]} = pieceNames;*)



If[
	FileExistsQ[packageDir <> "pieceImages.mx"]
	,
	pieceImages = Import[NotebookDirectory[] <> "pieceImages.mx"];
	Print["Chess piece images were loaded."];
	,
	piecePicLinksWiki =
		{
		"https://upload.wikimedia.org/wikipedia/commons/thumb/4/42/Chess_klt45.svg/75px-Chess_klt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Chess_qlt45.svg/75px-Chess_qlt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Chess_rlt45.svg/75px-Chess_rlt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Chess_blt45.svg/75px-Chess_blt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Chess_nlt45.svg/75px-Chess_nlt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Chess_plt45.svg/75px-Chess_plt45.svg.png"
		} ~Join~
		{
		"https://upload.wikimedia.org/wikipedia/commons/thumb/f/f0/Chess_kdt45.svg/75px-Chess_kdt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/4/47/Chess_qdt45.svg/75px-Chess_qdt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Chess_rdt45.svg/75px-Chess_rdt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Chess_bdt45.svg/75px-Chess_bdt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/Chess_ndt45.svg/75px-Chess_ndt45.svg.png",
		"https://upload.wikimedia.org/wikipedia/commons/thumb/c/c7/Chess_pdt45.svg/75px-Chess_pdt45.svg.png"
		};

	imagePicMotherLink = "https://marcelk.net/chess/pieces/merida/320/";
	piecePicLinks = Table["https://marcelk.net/chess/pieces/merida/320/" <> pieceName <> ".png", {pieceName, Most @ pieceNames}];

	pieceImages = 
		Import /@ piecePicLinks;
	AppendTo[pieceImages, Graphics[{Hue[0, 0, 1, 0], Rectangle[]}, ImageSize -> ImageDimensions @ First @ pieceImages]];
	Export[NotebookDirectory[]<>"pieceImages.mx",pieceImages];
	Print["Chess piece images were downloaded."];
]



pieceObj = 
	MapThread[
		#1 -> <|"Name" -> #2, "Symbol" -> #3, "Image" -> #4|>&,
		{pieceSymbols, pieceNames, pieceSymbols, pieceImages}
	];
	
pieceObj = Association @ pieceObj;



files = {"a", "b", "c", "d", "e", "f", "g", "h"};
fileSize = Length @ files;
ranks = {"1", "2", "3", "4", "5", "6", "7", "8"};
rankSize = Length @ ranks;

emptyBoard = Table[Mod[i + j, 2], {i, 8}, {j, 8}];
bottomLeftBlackBoard = Table[Mod[i + j    , 2], {i, 8}, {j, 8}];
bottomLeftWhiteBoard = Table[Mod[i + j + 1, 2], {i, 8}, {j, 8}];

(* Black Coordinate Matrix *)
bcm = \!\(\*
TagBox[
RowBox[{"(", "", GridBox[{
{"\"\<a8\>\"", "\"\<b8\>\"", "\"\<c8\>\"", "\"\<d8\>\"", "\"\<e8\>\"", "\"\<f8\>\"", "\"\<g8\>\"", "\"\<h8\>\""},
{"\"\<a7\>\"", "\"\<b7\>\"", "\"\<c7\>\"", "\"\<d7\>\"", "\"\<e7\>\"", "\"\<f7\>\"", "\"\<g7\>\"", "\"\<h7\>\""},
{"\"\<a6\>\"", "\"\<b6\>\"", "\"\<c6\>\"", "\"\<d6\>\"", "\"\<e6\>\"", "\"\<f6\>\"", "\"\<g6\>\"", "\"\<h6\>\""},
{"\"\<a5\>\"", "\"\<b5\>\"", "\"\<c5\>\"", "\"\<d5\>\"", "\"\<e5\>\"", "\"\<f5\>\"", "\"\<g5\>\"", "\"\<h5\>\""},
{"\"\<a4\>\"", "\"\<b4\>\"", "\"\<c4\>\"", "\"\<d4\>\"", "\"\<e4\>\"", "\"\<f4\>\"", "\"\<g4\>\"", "\"\<h4\>\""},
{"\"\<a3\>\"", "\"\<b3\>\"", "\"\<c3\>\"", "\"\<d3\>\"", "\"\<e3\>\"", "\"\<f3\>\"", "\"\<g3\>\"", "\"\<h3\>\""},
{"\"\<a2\>\"", "\"\<b2\>\"", "\"\<c2\>\"", "\"\<d2\>\"", "\"\<e2\>\"", "\"\<f2\>\"", "\"\<g2\>\"", "\"\<h2\>\""},
{"\"\<a1\>\"", "\"\<b1\>\"", "\"\<c1\>\"", "\"\<d1\>\"", "\"\<e1\>\"", "\"\<f1\>\"", "\"\<g1\>\"", "\"\<h1\>\""}
},
GridBoxAlignment->{"Columns" -> {{Center}}, "ColumnsIndexed" -> {}, "Rows" -> {{Baseline}}, "RowsIndexed" -> {}, "Items" -> {}, "ItemsIndexed" -> {}},
GridBoxSpacings->{"Columns" -> {Offset[0.27999999999999997`], {Offset[0.7]}, Offset[0.27999999999999997`]}, "ColumnsIndexed" -> {}, "Rows" -> {Offset[0.2], {Offset[0.4]}, Offset[0.2]}, "RowsIndexed" -> {}, "Items" -> {}, "ItemsIndexed" -> {}}], "", ")"}],
Function[BoxForm`e$, MatrixForm[BoxForm`e$]]]\);
(* White Coordinate Matrix *)
wcm = Reverse[bcm];
(* Usage: Position[wcm, "e1"]//First; *)

stateMatrix0 = \!\(\*
TagBox[
RowBox[{"(", "", GridBox[{
{"\[BlackRook]", "\[BlackKnight]", "\[BlackBishop]", "\[BlackQueen]", "\[BlackKing]", "\[BlackBishop]", "\[BlackKnight]", "\[BlackRook]"},
{"\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]", "\[BlackPawn]"},
{"\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]"},
{"\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]"},
{"\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]"},
{"\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]", "\[EmptySquare]"},
{"\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]", "\[WhitePawn]"},
{"\[WhiteRook]", "\[WhiteKnight]", "\[WhiteBishop]", "\[WhiteQueen]", "\[WhiteKing]", "\[WhiteBishop]", "\[WhiteKnight]", "\[WhiteRook]"}
},
GridBoxAlignment->{"Columns" -> {{Center}}, "ColumnsIndexed" -> {}, "Rows" -> {{Baseline}}, "RowsIndexed" -> {}, "Items" -> {}, "ItemsIndexed" -> {}},
GridBoxSpacings->{"Columns" -> {Offset[0.27999999999999997`], {Offset[0.7]}, Offset[0.27999999999999997`]}, "ColumnsIndexed" -> {}, "Rows" -> {Offset[0.2], {Offset[0.4]}, Offset[0.2]}, "RowsIndexed" -> {}, "Items" -> {}, "ItemsIndexed" -> {}}], "", ")"}],
Function[BoxForm`e$, MatrixForm[BoxForm`e$]]]\);


initialChessStateList = Thread[Flatten[bcm] -> Flatten[stateMatrix0]];
initialChessStateList = initialChessStateList ~Join~ {"\[WhiteRook]\[WhiteKing]" -> True, "\[WhiteKing]\[WhiteRook]" -> True, "\[BlackRook]\[BlackKing]" -> True, "\[BlackKing]\[BlackRook]" -> True, "EnPassant" -> None};
AppendTo[initialChessStateList, "WhiteCemetery" -> {}];
AppendTo[initialChessStateList, "BlackCemetery" -> {}];
AppendTo[initialChessStateList, "Turn" -> "White"];
AppendTo[initialChessStateList, "Result" -> {}];
initialChessStateList



ChessState[a_?AssociationQ][pos_?StringQ] /; StringMatchQ[pos, files ~~ ranks] := Lookup[a, pos, \[EmptySquare]]
ChessState[a_?AssociationQ][i_Integer, j_Integer] := ChessState[a][files[[i]] <> ranks[[j]]]
ChessState[a_?AssociationQ][{i_Integer, j_Integer}] := ChessState[a][i, j]
(*ChessState /: ChessState[a_?AssociationQ][pos_?StringQ] /; StringMatchQ[pos, files ~~ ranks] = v_ := ChessState*)
ChessState /: MakeBoxes[cs_ChessState, StandardForm] := 
	Module[{icon},
		icon = 
			ToBoxes[
				ImageResize[
					(*pieceObj[\[BlackKnight]]["Image"]*)
					Rasterize[ChessPlot[cs, "MatrixForm"-> True]]
					, 
					300
				]
		];
			
		InterpretationBox @@ 
			{
				RowBox[{"ChessState", "[", icon, "]"}],
			cs
			}
	]

InitializedChessState = ChessState[Association@initialChessStateList];



(* ChessPlot *)
tabulatePieceInset[insetToAlgFunc_, chessState_] :=
	Table[
		Inset[
			pieceObj[chessState[insetToAlgFunc[i, j]]]["Image"], 
			{i, j} - {1, 1}, 
			{i, j} - {1, 1}, 
			1
		]
		,
		{i, 8}
		, 
		{j, 8}
	];
			
tabulateCoordInset[insetToAlgFunc_] := 
	Table[
		Inset[
			Text[Style[insetToAlgFunc[i, j], 7]], 
			{i, j} + {-0.12, -0.09},
			Automatic,
			1
		]
		,
		{i, 8}
		,
		{j, 8}
	];
		

(* White \[Rule] Down, Origin is a1 *)
whiteDownCoordTable = 
	tabulateCoordInset[{i, j} \[Function] files[[i]] <> ranks[[j]]];
(* White \[Rule] Up, Origin is h8 *)
whiteUpCoordTable = 
	tabulateCoordInset[{i, j} \[Function] files[[9 - i]] <> ranks[[9 - j]]];
(* White \[Rule] Left, Origin is h1 *)
whiteLeftCoordTable = 
	tabulateCoordInset[{i, j} \[Function] files[[9 - j]] <> ranks[[i]]];
(* White \[Rule] right, Origin is a8 *)
whiteRightCoordTable =
	tabulateCoordInset[{i, j} \[Function] files[[j]] <> ranks[[9 - i]]];
		
Options[ChessPlot] = Join[
	{"WhiteOrientation" -> Automatic, "BoardColorSet" -> Automatic, "ShowCoordinates" -> True, "MatrixForm" -> False},
	Options[ArrayPlot]
];

ChessPlot[chessState_, opts: OptionsPattern[]] :=
	
	Module[{cs = First[chessState], pieceInset, coordInset, insetList, emptyBoard, plot, LightSquareColor, DarkSquareColor},
		(* Matrix Form *)
		If[OptionValue["MatrixForm"], 
			Return[
				MatrixForm[Partition[Values[cs[[ ;; rankSize fileSize]]], Length[files]]]
			]
		];
		
		(* Board Orientation *)
		Switch[
			OptionValue["WhiteOrientation"],
			Automatic | "Down",
				pieceInset = tabulatePieceInset[{i, j} \[Function] files[[i]] <> ranks[[j]], cs];
				coordInset = whiteDownCoordTable;
				emptyBoard = bottomLeftBlackBoard;
			,
			"Up",
				pieceInset = tabulatePieceInset[{i, j} \[Function] files[[9 - i]] <> ranks[[9 - j]], cs];
				coordInset = whiteUpCoordTable;
				emptyBoard = bottomLeftBlackBoard;
			,
			"Left",
				pieceInset = tabulatePieceInset[{i, j} \[Function] files[[9 - j]] <> ranks[[i]], cs];
				coordInset = whiteLeftCoordTable;
				emptyBoard = bottomLeftWhiteBoard;
			,
			"Right",
				pieceInset = tabulatePieceInset[{i, j} \[Function] files[[j]] <> ranks[[9 - i]], cs];
				coordInset = whiteRightCoordTable;
				emptyBoard = bottomLeftWhiteBoard;
			,
			_,
				Print["Wrong \"WhiteOrientation\" option was provided. Try \"Up\" for instance."]; Return[$Failed];
		];
		
		(* Board Color *)
		Switch[
			OptionValue["BoardColorSet"],
			Automatic,
				LightSquareColor = RGBColor[1.0, 0.8, 0.6];
				DarkSquareColor  = RGBColor[0.8, 0.5, 0.3];
			,
			{_?ColorQ, _?ColorQ},
				{LightSquareColor, DarkSquareColor} = OptionValue["BoardColorSet"];
			,
			_,
				Print["Wrong \"BoardColorSet\" Sepcified. Try {White, Gray} for instance."]; Return[$Failed];
		];
		
		Switch[
			OptionValue["ShowCoordinates"],
			True,
				insetList = pieceInset ~Join~ coordInset;
			,
			False,
				insetList = pieceInset ~Join~ {};
			,
			_,
				Print["\"ShowCoordinates\" can either be True or False."]; Return[$Failed];
		];
		
		plot = 		
			ArrayPlot[
				emptyBoard,
				ColorRules -> {0 -> LightSquareColor, 1 -> DarkSquareColor}, 
				Epilog -> insetList,
				FilterRules[{opts}, Options[ArrayPlot]]
			];
		
		plot
	]
	
(* Shortcuts *)
mp = ChessPlot[#, "MatrixForm" -> True]&;
fp = ChessPlot[#, "MatrixForm" -> False]&;

(* Chess Rules *)

(* A. Empty Square *)

inRangeQ[pos_] :=
	Module[{cond1, cond2},
	cond1 = (1 <= pos[[1]] <= rankSize);
	cond2 = (1 <= pos[[2]] <= fileSize);
	Return[(cond1 \[And] cond2)];
	]

(* B. Pawn *)

B1[ch_] :=
	Module[{S = First[Last[ch]], actions, turn, piece, pos1List, coordMatrix, pos1, pos2, pos3, coord2, cond1, cond2, act1, act2},
		actions = {};
		(* Whose turn is it? *)
		turn = Mod[Length@ch + 1, 2] + 1;
		piece = Part[{\[WhitePawn], \[BlackPawn]}, turn];
		coordMatrix = Part[{wcm, bcm}, turn];
		
		pos1List = Position[S, piece][[All, 1, 1]];
		
		Do[
			pos1 = Position[coordMatrix, coord1]//First;
			
			pos2  = pos1 + {1, 0};
			If[!inRangeQ[pos2], Break[];];
			coord2 = Extract[coordMatrix, pos2];
			
			(* The case for going to the last rank *)
			cond1 = pos1[[1]] == rankSize;
			(* The square in front of it must be empty *)
			cond2 = S[coord2] == \[EmptySquare];
			(* Move from coord1 to coord2 *)
			act1 = (coord1 -> \[EmptySquare]);
			act2 = (coord2 -> piece);
			
			If[!cond1 \[And] cond2, 
				AppendTo[actions, {act1, act2}];
			];
						
			If[cond1 \[And] cond2, 
				AppendTo[actions, {coord1 -> \[EmptySquare], coord1 -> Part[{\[WhiteQueen], \[BlackQueen]}, turn]}];
				AppendTo[actions, {coord1 -> \[EmptySquare], coord1 -> Part[{\[WhiteRook], \[BlackRook]}, turn]}];
				AppendTo[actions, {coord1 -> \[EmptySquare], coord1 -> Part[{\[WhiteBishop], \[BlackBishop]}, turn]}];
				AppendTo[actions, {coord1 -> \[EmptySquare], coord1 -> Part[{\[WhiteKnight], \[BlackKnight]}, turn]}];
			];
			,
			{coord1, pos1List}
		];
		actions = DeleteDuplicates @ actions;
		Return[actions];
	]

B3[ch_] :=
	Module[{S = First[Last[ch]], actions, turn, piece, pos1List, steps, coordMatrix, pos1, pos2, pos3, coord2, coord3, cond1, cond2, opponentCemetery, opponentPieces},
		actions = {};
		(* Whose turn is it? *)
		turn = Mod[Length@ch + 1, 2] + 1;
		piece = Part[{\[WhitePawn], \[BlackPawn]}, turn];
		(* Rest is to remove the king *)
		opponentPieces = Part[{Rest @ blackPieces, Rest @ whitePieces}, turn];
		opponentCemetery =  Part[{"blackCemetery", "whiteCemetery"}, turn];
		coordMatrix = Part[{wcm, bcm}, turn];
		
		pos1List = Position[S, piece][[All, 1, 1]];
		steps = {{1, -1}, {1, +1}};
		
		Do[
			pos1 = Position[coordMatrix, coord1]//First;
			Do[
				pos2  = pos1 + step;
				If[!inRangeQ[pos2], Continue[];];
				coord2 = Extract[coordMatrix, pos2];
				
				(* Must be at rank 2 *)
				cond1 = pos2[[1]] == rankSize;
				(* The two squares in front of it must be empty *)
				cond2 = MemberQ[opponentPieces, S[coord2]];
				If[!cond1 \[And] cond2, 
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> piece}];
				];
							
				If[cond1 \[And] cond2, 
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> Part[{\[WhiteQueen], \[BlackQueen]}, turn]}];
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> Part[{\[WhiteRook], \[BlackRook]}, turn]}];
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> Part[{\[WhiteBishop], \[BlackBishop]}, turn]}];
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> Part[{\[WhiteKnight], \[BlackKnight]}, turn]}];
				];
			,
			{step, steps}
			];
			,
			{coord1, pos1List}
		];
		actions = DeleteDuplicates @ actions;
		Return[actions];
	]
	


KnightMove[ch_] :=
	Module[{S = First[Last[ch]], actions, turn, piece, pos1List, steps, coordMatrix, pos1, pos2, pos3, coord2, coord3, cond1, cond2, opponentCemetery, opponentPieces},
		actions = {};
		(* Whose turn is it? *)
		turn = Mod[Length@ch + 1, 2] + 1;
		piece = Part[{\[WhiteKnight], \[BlackKnight]}, turn];
		(* Rest is to remove the kings *)
		opponentPieces = Part[{Rest @ blackPieces, Rest @ whitePieces}, turn];
		opponentCemetery =  Part[{"blackCemetery", "whiteCemetery"}, turn];
		coordMatrix = Part[{wcm, bcm}, turn];
		
		pos1List = Position[S, piece][[All, 1, 1]];
		steps = {{-2, -1}, {-2, +1}, {-1, -2}, {-1, +2}, {+1, -2}, {+1, +2}, {+2, -1}, {+2, +1}};
		
		Do[
			pos1 = Position[coordMatrix, coord1]//First;
			Do[
				pos2  = pos1 + step;
				If[!inRangeQ[pos2], Continue[];];
				coord2 = Extract[coordMatrix, pos2];
				(* The two squares in front of it must be empty *)
				cond1 = MemberQ[opponentPieces ~Join~ {\[EmptySquare]}, S[coord2]];

				If[cond1 \[And] S[coord2] == \[EmptySquare], 
					AppendTo[actions, {coord1 -> \[EmptySquare], coord2 -> piece}];
				];
				If[cond1 \[And] S[coord2] != \[EmptySquare],
					AppendTo[actions, {coord1 -> \[EmptySquare], S[coord2] -> opponentCemetery, coord2 -> piece}];
				]
				,
				{step, steps}
			];
			,
			{coord1, pos1List}
		];
		actions = DeleteDuplicates @ actions;
		Return[actions];
	]
	
C1 = KnightMove;


ChessEvolve[chessHistory_, actions:{__Rule}] := 
	Module[{S = First[Last[chessHistory]]},
		Do[
			S[action[[1]]] = action[[2]];
			,
			{action, actions}
		];
		Return[chessHistory ~Join~ {ChessState[S]}];
	]


End[]
EndPackage[]