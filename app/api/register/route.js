import { userService } from "@/services/userService";
import { NextRequest, NextResponse } from "next/server";


export async function POST(request, response) {

    const { username, email, password } = request.body;

    try{
        const user = await userService.register({username, email, password});
        return NextResponse.json(user, { status: 201 })
    } catch(error) {
        return NextResponse.json(error);
    }
    

}