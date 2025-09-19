import { userService } from "@/services/userService";
import { NextResponse, NextRequest } from "next/server";

export async function GET(request) {
    try {
        const username = request.nextUrl.searchParams.get("username");

        if (!username) {
            return NextResponse.json({ message: "Username not provided." }, { status: 400 });
        }

        const user = await userService.logout({ username });
        return NextResponse.json(user, { status: 200 });

    } catch (error) {
        return NextResponse.json({ message: error.message }, { status: 400 });
    }
}