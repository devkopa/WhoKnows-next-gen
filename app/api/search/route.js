import { pagesService } from "@/services/pagesService";
import { NextRequest, NextResponse } from "next/server";


export async function GET(request) {
    
    const searchParams = request.nextUrl.searchParams;
    const searchString = searchParams.get('q');
    const language = searchParams.get('language');

    let searchResults = [];
    

    if(searchString && language) {
        searchResults = await pagesService.findBySearch(searchString, language);
        
    }

    return NextResponse.json(searchResults);

}