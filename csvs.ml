open Base
open Stdio

(* Iterate through rows and get the largest widths *)
let max_widths header rows =
        let lengths l = List.map ~f:String.length l in
        List.fold rows
                ~init:(lengths header)
                ~f:(fun acc row ->
                        List.map2_exn ~f:Int.max acc (lengths row))


(* Render the horizontal separator line *)
let render_separator widths =
        let pieces = List.map widths
                ~f:(fun w -> String.make(w + 2) '_')
        in
        "|" ^ String.concat ~sep:"+" pieces ^ "|"

(* Pad strings to a specific length *)
let pad s length =
        " " ^ s ^ String.make (length - String.length s + 1) ' '

(* Render a row of data *)
let render_row row widths =
        let padded = List.map2_exn row widths ~f:pad in
        "|" ^ String.concat ~sep:"|" padded ^ "|"


(* Render the table *)
let render_table header rows =
        let widths = max_widths header rows in 
        String.concat ~sep:"\n"
                (render_row header widths 
                 :: render_separator widths
                 :: List.map rows ~f:(fun row -> render_row row widths)
                )

(* Split string by separator *)
let split_by sep x = String.split ~on:sep x 


(* Match substring in string *)
let match_in s1 s2 =
	let s1 = String.lowercase s1 and
	s2 = String.lowercase s2 and
	len1 = String.length s1	and
	len2 = String.length s2 in
	if len1 < len2 then false else
		let rec aux i =
      			if i < 0 then false else
        			let sub = String.sub s1 ~pos:i ~len:len2 in
        			if String.equal sub s2 then true else aux (Int.pred i)
    	in
    	aux (len1 - len2)

let print_usage () =
	Stdio.print_endline("Usage: csvs file separator search_string\n")

let () =
	(* Parse cmd arguments *)
	if (Array.length Sys.argv) <> 4 then print_usage () else
	let file = Sys.argv.(1) in
	let sep = String.get Sys.argv.(2) 0 in
	let search = Sys.argv.(3) in

	(* Read file *)
	let ic = In_channel.create file in
	let rec build_list infile idx =	
		try
  			let line = In_channel.input_line_exn infile in
			let splitted = if idx = 0 || match_in line search then 
				split_by sep line 
				else [] in
			match splitted with
			| [] -> build_list infile (Int.succ idx)
			| _  -> splitted :: build_list infile (Int.succ idx)     			
  		with End_of_file ->
  			In_channel.close infile;
			[] in
	let lst = build_list ic 0 in
	match lst with    
		| [] | _::[] -> Stdio.print_endline ("Value not found.\n")
		| hd::tl -> Stdio.print_endline (render_table hd tl ^ "\n")
