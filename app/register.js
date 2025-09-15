import { userService } from "@/services/userService";
import { NextResponse, NextRequest } from "next/server";

export async function GET(request) {
    try {
        
        const searchParams = request.nextUrl.searchParams;
        const username = searchParams.get("username");
        const email = searchParams.get("email");
        const password = searchParams.get("password");    

        if (!username) {
            return NextResponse.json({ message: "Username cannot be empty." }, { status: 400 });
        }

        if (!password) {
            return NextResponse.json({ message: "Password cannot be empty." }, { status: 400 });
        }

        if (!email) {
            return NextResponse.json({ message: "Email cannot be empty." }, { status: 400 });
        }

        if (email === null || !email.includes("@")) {
            return NextResponse.json({ message: "Email is not valid." }, { status: 400 });
        }

        const user = await userService.register({ username, email, password });
        return NextResponse.json(user, { status: 200 });

    } catch (error) {
        return NextResponse.json({ message: error.message }, { status: 400 });
    }
}