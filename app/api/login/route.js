import { userService } from "@/services/userService";
import { NextResponse } from "next/server";


export async function POST(request) {

    const { username, email, password } = await request.json();

    try{
        const user = await userService.login({username, password});
        return NextResponse.json(user, { status: 200 });
    } catch(error) {
        return NextResponse.json(error);
    }
    
}