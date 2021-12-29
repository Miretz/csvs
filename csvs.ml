open Base
open Stdio

(* Command line arguments type *)
type arguments_complete = { file: string; sep: string; search: string; }
type arguments = | Arguments_Missing
				 | Arguments of arguments_complete
			

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


(* Regex pattern to ignore quoted strings *)
let unquoted_pat = "\"[^\"]*\"(*SKIP)(*F)|"


(* Split string by separator *)
let split_by sep x = 
	let pattern = unquoted_pat ^ sep in
	Pcre.split ~pat:pattern x


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


(* Prints the usage of the program *)
let print_usage () =
	Stdio.print_endline("Usage: csvs file separator [search_string]\n")


(* Read and process the file line by line *)
let build_list { file; sep; search } =	
	let ic = In_channel.create file in
	let rec build_list_inner lst =
		try
  			let line = In_channel.input_line_exn ic in
			let splitted = if List.is_empty lst || match_in line search then 
				split_by sep line 
				else [] in
			match splitted with
			| [] -> build_list_inner lst
			| _  -> build_list_inner (splitted::lst)     			
  		with End_of_file ->
  			In_channel.close ic;
			List.rev lst in
	build_list_inner []


(* Read command line arguments *)
let read_cmd_args argv = 
	let arg_len = Array.length argv in
	if arg_len < 3 || arg_len > 4 then Arguments_Missing else
	Arguments {
		file=argv.(1); 
		sep=argv.(2); 
		search=if arg_len = 4 then argv.(3) else "";
	}


(* Main function *)
let () =
	let args = read_cmd_args (Sys.get_argv()) in
	match args with
	| Arguments_Missing -> print_usage ()
	| Arguments args ->
		let lst = build_list args in
		Stdio.print_endline ("Entries found: " ^ Int.to_string ((List.length lst)-1) ^"\n");
		match lst with    
			| [] | _::[] -> Stdio.print_endline ("Value not found.\n")
			| hd::tl -> Stdio.print_endline (render_table hd tl ^ "\n")
