#################################################################
#          POWER CHESS
#################################################################


<#
.SYNOPSIS
    PowerChess a powershell GUI chess game
.NOTES
    Name: Chess.ps1
    Version: 1.0
    Author: captnemo
    Date: 6/16/2020
.CHANGELOG
         
.EXAMPLE
        .\powerChess.ps1 
.TO DO 
     
	
#>
#Create Game object


$Game = New-Object -TypeName PSObject
$board = New-Object 'object[,]' 8,8
$buttons = @{ }
#create Move from to 
[array]$movePositions =@(" "," ")
#array of pieces
$Pieces = @()
#player (whose turn is it)
$player = "White"

#function to create a new piece 
function newPiece(){
Param(
	[string]$name,
	[string]$piecetype,
	[string]$color,
	[int]$row,
	[int]$col,
	[string]$Image
)
$Piece = New-Object -TypeName PSObject -Property @{Name=$name;
piecetype=$piecetype;
color=$color;
Position=@{row=$row;col=$col};
startPosition=@{row=$row;col=$col};
Image=$Image;
firstMove = $true 
}
return $Piece
}

#creating pieces and adding to pieces array
# each piece has:   Name  piecetype color row col and imagefile 
#(row and col are used for both position and starting position)
$pieces += newPiece wht_pawn1 pawn white 1 	0 	pawn_white.png
$pieces += newPiece wht_pawn2 pawn white 1 	1 	pawn_white.png
$pieces += newPiece wht_pawn3 pawn white 1 	2 	pawn_white.png
$pieces += newPiece wht_pawn4 pawn white 1 	3 	pawn_white.png
$pieces += newPiece wht_pawn5 pawn white 1 	4 	pawn_white.png
$pieces += newPiece wht_pawn6 pawn white 1 	5 	pawn_white.png
$pieces += newPiece wht_pawn7 pawn white 1 	6 	pawn_white.png
$pieces += newPiece wht_pawn8 pawn white 1 	7 	pawn_white.png

$pieces += newPiece wht_rook1   rook   	white 0 0 rook_white.png
$pieces += newPiece wht_knight1 knight 	white 0 1 knight_white.png
$pieces += newPiece wht_bishop1 bishop 	white 0 2 bishop_white.png
$pieces += newPiece wht_queen 	queen  	white 0 3 queen_white.png
$pieces += newPiece wht_king 	king 	white 0 4 king_white.png
$pieces += newPiece wht_bishop2 bishop 	white 0 5 bishop_white.png
$pieces += newPiece wht_knight2 knight 	white 0 6 knight_white.png
$pieces += newPiece wht_rook2 	rook 	white 0 7 rook_white.png

$pieces += newPiece blk_pawn1 pawn black 6 	0 	pawn_black.png
$pieces += newPiece blk_pawn2 pawn black 6 	1 	pawn_black.png
$pieces += newPiece blk_pawn3 pawn black 6 	2 	pawn_black.png
$pieces += newPiece blk_pawn4 pawn black 6 	3 	pawn_black.png
$pieces += newPiece blk_pawn5 pawn black 6 	4 	pawn_black.png
$pieces += newPiece blk_pawn6 pawn black 6 	5 	pawn_black.png
$pieces += newPiece blk_pawn7 pawn black 6 	6 	pawn_black.png
$pieces += newPiece blk_pawn8 pawn black 6 	7 	pawn_black.png

$pieces += newPiece blk_rook1   rook   	black 7 0 rook_black.png
$pieces += newPiece blk_knight1 knight 	black 7 1 knight_black.png
$pieces += newPiece blk_bishop1 bishop 	black 7 2 bishop_black.png
$pieces += newPiece blk_queen 	queen  	black 7 3 queen_black.png
$pieces += newPiece blk_king 	king 	black 7 4 king_black.png
$pieces += newPiece blk_bishop2 bishop 	black 7 5 bishop_black.png
$pieces += newPiece blk_knight2 knight 	black 7 6 knight_black.png
$pieces += newPiece blk_rook2 	rook 	black 7 7 rook_black.png
#clearboard method
$ClearBoard =
{
for($row=0;$row -lt 8;$row++){
	for($col=0;$col -lt 8;$col++){
		$this.board[$row,$col]= $null
	}
  }
}

#resetBoard method
$resetBoard = {
foreach($piece in $Pieces){
	$row = $Piece.startPosition.row
	$col = $Piece.startPosition.col
	$piece.firstMove =$true
	$this.board[$row,$col] = $Piece
	}
}
#add to game
Add-Member -InputObject $game -MemberType ScriptMethod -Name ClearBoard -Value $ClearBoard
Add-Member -InputObject $game -MemberType ScriptMethod -Name resetBoard -Value $resetBoard
Add-Member -InputObject $game -MemberType NoteProperty -Name board -Value  $board
Add-Member -InputObject $game -MemberType NoteProperty -Name moveToFrom -Value  $movePositions
Add-Member -InputObject $game -MemberType NoteProperty -Name buttons -Value  $buttons
Add-Member -InputObject $game -MemberType NoteProperty -Name player -Value  $player
 $game.ClearBoard()
 $game.resetBoard()
 
function clickedbutton(){
	Param([String]$button)
		if($Game.MoveToFrom[0] -eq " "){
			$Game.MoveToFrom[0] = $button
			$selectedButton = $Game.buttons[$button]
			draw-board
			$selectedButton.BackColor ="Yellow" 
		}
		else{
			$Game.moveToFrom[1] =$button
			$destinationButton = $Game.buttons[$button]
			$destinationButton.BackColor ="Red" 
			move-piece $Game.moveToFrom[0] $Game.moveToFrom[1]
			$Game.moveToFrom[0] = " "
			$Game.moveToFrom[1] = " "

}
}

Function Move-Piece {
    Param ($source,$dest)
	[int]$startRow = $source.Substring(0,1)
	[int]$startCol = $source.Substring(1,1) 
	[int]$destRow = $dest.Substring(0,1) 
	[int]$destCol = $dest.Substring(1,1) 
	$attacking = $false
 $piece = $Game.board[$startRow,$startCol]
  
 if($piece.color -ne $Game.player){
 writeMessage "Error not your turn"
 return
 }
 
 #Casteling 
 if($piece.piecetype -eq "rook" -and $Game.board[$destRow,$destCol].piecetype -eq "king" -and $Game.board[$destRow,$destCol].color -eq $piece.color){
 if($piece.firstMove -eq $false -or $Game.board[$destRow,$destCol].firstMove -eq $false ){
 writeMessage "Error you cannot castle if you've moved either piece"
		return
 }
 if($startCol -lt $destCol){
	for ($col = $startCol+1;$col -lt $destCol;$col++){
		if($Game.board[$destRow,$col] -ne $null){
		writeMessage "Error you cannot castle with pieces in the way"
		return
		}
	}
	SuccesfulCastle $($startRow)  $($startCol+1) $($startRow) $($startCol+2) 
	return
	}
if($startCol -gt $destCol){
	for ($col = $destCol+1;$col -lt $startCol;$col++){
		if($Game.board[$destRow,$col] -ne $null){
		writeMessage "Error you cannot castle with pieces in the way"
		return
		}
	}
	SuccesfulCastle $($startRow)  $($startCol-1) $($startRow) $($startCol-2) 
	return
	}	
 } # end casteling
 
 if($Game.board[$destRow,$destCol].color -eq $Game.Player){
	 writeMessage "Error square occupied"
	 return
 } 
 if($Game.board[$destRow,$destCol]){
	$attacking = $true
 } 
 $RowDist = $startRow - $destRow
 $ColDist = $startCol - $destCol
 #write-host "start = $startRow,$startCol dest = $destRow,$destCol"
 #write-host "row dist $RowDist col dist $ColDist"
 #write-host $piece.piecetype
 
	# PAWN PROMOTION 
 if($piece.piecetype -eq "pawn"){ 
 if($StartRow -eq 0 -or $startRow -eq 7){
  $piece.piecetype = "queen"
  if($piece.color -eq "white"){
	$piece.image = "queen_white.png"
	} else{
		$piece.image = "queen_black.png"
	}
	SuccesfulMove
	return
  }
  }
  
  # pawn move
  if($piece.piecetype -eq "pawn"){ 
  $result = pawnMoves $piece $startRow $destRow
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
	
  }
  
  	# KNIGHT moves 
 if($piece.piecetype -eq "knight"){
	$result = knightMoves
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
 } #END KNIGHT
 
   	# ROOK moves 
 if($piece.piecetype -eq "rook"){
	$result = rookMoves
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
 } # END ROOK
 
 # BISHOP moves 
 if($piece.piecetype -eq "bishop"){
	$result = bishopMoves
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
 } # END BISHOP
 
 # KING moves 
 if($piece.piecetype -eq "king"){
  $result = kingMoves
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
 }#END KING move
 
 # QUEEN moves 
 if($piece.piecetype -eq "queen"){   
  $result = queenMoves
	if($result){
	SuccesfulMove
	return
	}else{
	writeMessage "Error invalid move"
	 return
	}
 }#END QUEEN move

 }# END move-piece function
 # ++++++++++++++++++++++++
 
 function kingMoves(){
	if($RowDist -gt 1 -or $RowDist -lt -1 -or $ColDist -gt 1 -or $ColDist -lt -1){
	return $false
	} 
return $true
 }#end king moves
 
 function queenMoves(){
 #write-host "queen $RowDist $ColDist"
	if( ($RowDist -gt 0 -or $RowDist -lt 0) -and ($ColDist -gt 0 -or $ColDist -lt 0) -AND ( !( ( ($startRow + $startCol) -eq ($destRow +$destCol) ) -or (
	($startCol - $startRow ) -eq ($destCol -$destRow)) ) )
	) {
		return $false	
	}
	 if($RowDist -eq 0 -and $ColDist -lt 0){ #moving right
	for($col = $startCol+1;$col -lt $destCol;$col++){
	 if($game.board[$startRow,$col] -ne $null){
		return $false
		}
		}
	}
	if($RowDist -eq 0 -and $ColDist -gt 0){ #moving left
	for($col = $destCol+1;$col -lt $startCol;$col++){
	 if($game.board[$startRow,$col] -ne $null){
		return $false
		}
		}
	}
	if($ColDist -eq 0 -and $RowDist -lt 0){ #moving down
	for($row = $startRow+1;$row -lt $destRow;$row++){
	 if($game.board[$row,$startCol] -ne $null){
		return $false
		}
		}
	}
	if($ColDist -eq 0 -and $RowDist -gt 0){ #moving up
	for($row = $destRow+1;$row -lt $startRow;$row++){
	 if($game.board[$row,$startCol] -ne $null){
		return $false
		}
		}
	}
		#diagonals 
		#write-host " queen diagonal"
	if (($startRow + $startCol) -eq ($destRow +$destCol) ){
		$col = $startCol
		if($startRow -lt $destRow){
			for($row = $startRow+1;$row -lt $destRow;$row++){
			$col = $col-1			
			if($game.board[$row,$col] -ne $null){
			return $false
					}
				}
			}
			if($startRow -gt $destRow){
			$col = $destCol
			for($row = $destRow+1;$row -lt $startRow;$row++){
			$col = $col-1
			#write-host "2. checking $row $col"
			if($game.board[$row,$Col] -ne $null){
					return $false
					}
				}
			}
		}
		
	if ( ( $startCol - $startRow ) -eq ($destCol -$destRow) ){
		$row = $destRow
		if($startCol -gt $destCol){	
			for($col = $destCol+1;$Col -lt $startCol;$col++){
			$row = $row+1
			if($game.board[$row,$Col] -ne $null){
					return $false
					}
				}
			}
			if($startCol -lt $destCol){
			$row = $startRow
			for($col = $startCol+1;$Col -lt $destCol;$col++){
			$row = $row+1
			if($game.board[$row,$Col] -ne $null){
					return $false
					}
				}
			}
		}
 return $true
 } #end queen moves
 
 
 function bishopMoves(){
 if( ($RowDist -eq 0 -or $colDist -eq 0)  ) {		
		return $false	
	}
	 
	if ( !(( ($startRow + $startCol) -eq ($destRow +$destCol) ) -or (
	( $startCol - $startRow ) -eq ($destCol -$destRow)) ) 
	){
	 	return $false	
	}
	if (($startRow + $startCol) -eq ($destRow +$destCol) ){
		$col = $startCol
		#write-host "diagonal"
		if($startRow -lt $destRow){
			for($row = $startRow+1;$row -lt $destRow;$row++){
			$col = $col-1
			if($game.board[$row,$Col] -ne $null){
					return $false	
					}
				}
			}
			if($startRow -gt $destRow){
			$col = $destCol
			for($row = $destRow+1;$row -lt $startRow;$row++){
			$col = $col-1
			if($game.board[$row,$Col] -ne $null){
					return $false		
					}
				}
			}
		}
		
	if ( ( $startCol - $startRow ) -eq ($destCol -$destRow) ){
		$row = $destRow
		if($startCol -gt $destCol){	
			for($col = $destCol+1;$Col -lt $startCol;$col++){
			$row = $row+1
			if($game.board[$row,$Col] -ne $null){
					return $false		
					}
				}
			}
			if($startCol -lt $destCol){
			$row = $startRow
			for($col = $startCol+1;$Col -lt $destCol;$col++){
			$row = $row+1
			if($game.board[$row,$Col] -ne $null){
				return $false	
					}
				}
			}
		}
	return $true
}#end move bishop function
 
 function rookMoves() {
 if( ($RowDist -gt 0 -or $RowDist -lt 0) -and ($ColDist -gt 0 -or $ColDist -lt 0) ) {
		return $false
	}
	if($RowDist -eq 0 -and $ColDist -lt 0){ #moving right
	for($col = $startCol+1;$col -lt $destCol;$col++){
	 if($game.board[$startRow,$col] -ne $null){
		return $false
		}
		}
	}
	if($RowDist -eq 0 -and $ColDist -gt 0){ #moving left
	for($col = $destCol+1;$col -lt $startCol;$col++){
	 if($game.board[$startRow,$col] -ne $null){
		return $false
		}
		}
	}
	if($ColDist -eq 0 -and $RowDist -lt 0){ #moving down
	for($row = $startRow+1;$row -lt $destRow;$row++){
	 if($game.board[$row,$startCol] -ne $null){
		return $false	
		}
		}
	}
	if($ColDist -eq 0 -and $RowDist -gt 0){ #moving up
	for($row = $destRow+1;$row -lt $startRow;$row++){
	 if($game.board[$row,$startCol] -ne $null){
		return $false	
		}
		}
	}
	return $true
 }#end rook moves
 
 function knightMoves(){
 if( ($ColDist -eq 2 -or  $ColDist -eq -2) -and ($RowDist -eq 1 -or $RowDist -eq -1) ){
	return $true
	}
	if( ($ColDist -eq 1 -or  $ColDist -eq -1) -and ($RowDist -eq 2 -or $RowDist -eq -2) ){	 
	return $true
	}
	return $false
} #end knight moves

 # PAWN moves 
 function pawnMoves(){
 param(
	$piece ,
	$startRow,
	$destRow
 )
   #write-host $piece.color $RowDist
	if( ($piece.color -eq "white" -and ( $destRow -lt $StartRow)) -or ($piece.color -eq "black" -and ( $destRow -gt $StartRow))  ){
		#writeMessage "Invalid move(wrong direction)"
		return $false	
	}
 if ($attacking ){
   if( ($ColDist -eq 1 -or $ColDist -eq -1) -and ($RowDist -eq 1 -or $RowDist -eq -1) ){
		#SuccesfulMove
		return $true
		}
		#writeMessage "Invalid move(must move diagonal to attack)"
		return $false
	} 

	
	if ($ColDist -gt 0 -or $colDist -lt 0 -or $RowDist -gt 2 -or $RowDist -lt -2){
	#writeMessage "Invalid move"
	return $false
	}
	if( ($RowDist -eq 2 -or $RowDist -eq -2) -and $piece.firstMove -eq $false){
		#writeMessage "Invalid move"
		return $false	
	}
	#SuccesfulMove
	return $true
   
  }# END PAWN Moves
 # ========================
 function inCheck(){
	for($row=0;$row -lt 8;$row++){
		for($col=0;$col -lt 8;$col++){
			if($Game.board[$row,$col].piecetype -eq "king" -and $Game.board[$row,$col].color -eq $Game.player){
			$king = $Game.board[$row,$col]
			}
		}
	}
	
 }
 # ++++++++++++++++++++++++
 
 function SuccesfulMove(){
 #Succesful move 
 $Game.board[$startRow,$startCol] = $null
 $piece.position.row = $destRow
 $piece.position.col =$destCol
 $piece.firstMove = $false
 $Game.board[$destRow,$destCol] = $piece
 
 if($Game.player -eq "White"){
	$Game.player = "Black"
	}else{
	$Game.player ="White"
	}
	draw-board
	writeMessage "It's $($Game.player)'s turn"
}

function SuccesfulCastle(){
param(
$newKingRow,$newKingCol,
$newRookRow,$newRookCol
)
 $Game.board[$newKingRow,$newKingCol]=$Game.board[$destRow,$destCol]
 $Game.board[$newRookRow,$newRookCol]=$Game.board[$startRow,$startCol]
 $Game.board[$startRow,$startCol] = $null
 $Game.board[$destRow,$destCol] = $null  
 $Game.board[$newKingRow,$newKingCol].firstMove = $false
   
 if($Game.player -eq "White"){
	$Game.player = "Black"
	}else{
	$Game.player ="White"
	}
	draw-board
	writeMessage "It's $($Game.player)'s turn"
}

# = DRAW Board ===================
function draw-board{
$alternate=$false
	for ($x =0;$x -le 7;$x++){
			$alternate = !$alternate
		for ($y =0;$y -le 7;$y++){
			$index ="$x$y"
			$button = $Game.buttons[$index]
		
		if($Game.board[$x,$y].Image){
			$imagename		= $Game.board[$x,$y].Image
			$image = [System.Drawing.Image]::FromFile("$PWD\images\$imagename")
			$button.BackgroundImage	= $image
			}else{
			$imagename		= "clear.png"
			$image = [System.Drawing.Image]::FromFile("$PWD\images\$imagename")
			$button.BackgroundImage	= $image
			}
			
		if($alternate){
				$button.BackColor ="Black" 
				$alternate = $false
			}else{
				$button.BackColor ="White" 
				$alternate = $true
			}
		}
	}

}
# ============================================

#WRITE MESSAGE TO PLAYER
Function WriteMessage(){
Param ([String]$message)
$MaskedTextBox1.text = $message
}

# ===========================================================================
#  ============== Form to display GUI =======================================
 Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
Add-Type -Assembly System.Drawing 
$Form = New-Object system.Windows.Forms.Form
$squaresize =80                           
[int32]$height = $squaresize * 10
[int32]$width = $squaresize * 9
$Form.ClientSize                 = "$width,$height"
$Form.text                       = "PowerChess"
$Form.TopMost                    = $false

$MaskedTextBox1                  = New-Object system.Windows.Forms.MaskedTextBox
$MaskedTextBox1.multiline        = $false
$MaskedTextBox1.text                  = "listView"
$MaskedTextBox1.width                 = $squaresize *8
$MaskedTextBox1.height                = 86
$MaskedTextBox1.location              = New-Object System.Drawing.Point(16,21)

$alternate = $false

for ($x =0;$x -le 7;$x++){
 $alternate = !$alternate
 for ($y =0;$y -le 7;$y++){

$button = New-Object system.Windows.Forms.Button

$button.width                   = $squaresize
$button.height                  = $squaresize
$height = ($squaresize * $x)+110
$width =  ($squaresize * $y)+11
$button.location                = New-Object System.Drawing.Point($width,$height)
$button.Font                    = 'Microsoft Sans Serif,10'
$button.BackgroundImageLayout = 'Stretch'
if($Game.board[$x,$y].Image){
 
$imagename		= $Game.board[$x,$y].Image

#write-host $imagename
try{
$image = [System.Drawing.Image]::FromFile("$PWD\images\$imagename")
}catch{
write-output "Error image file $imagename not found"
}
$button.BackgroundImage	= $image

}
	if($alternate){
		$button.BackColor ="Black" 
		$alternate = $false
		}else{
			$button.BackColor ="White" 
			$alternate = $true
	}


$Game.buttons.Add(("$x$y"),$button)
$button.Name = "$x$y"
$button.Add_Click({
clickedbutton $this.name
#Write-host $this.name
})

New-Variable -name button_$x$y -Value $button

$Form.controls.Add($((Get-Variable -name button_$x$y).value))
}
}
$Form.controls.AddRange(@($MaskedTextBox1  ))

#Start form 
[void]$Form.ShowDialog()
# ===================================================================
#The End